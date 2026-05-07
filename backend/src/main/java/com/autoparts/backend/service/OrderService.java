package com.autoparts.backend.service;

import com.autoparts.backend.domain.entity.*;
import com.autoparts.backend.domain.enums.OrderStatus;
import com.autoparts.backend.domain.enums.QuoteStatus;
import com.autoparts.backend.dto.OrderDto;
import com.autoparts.backend.dto.OrderRequest;
import com.autoparts.backend.dto.QuoteDto;
import com.autoparts.backend.exception.BusinessException;
import com.autoparts.backend.exception.ResourceNotFoundException;
import com.autoparts.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final QuoteRepository quoteRepository;
    private final UserRepository userRepository;

    // ── Orders ──────────────────────────────────────────────────────

    @Transactional
    public OrderDto placeOrder(Long clientId, OrderRequest request) {
        User client = userRepository.findById(clientId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + clientId));

        List<OrderItem> items = new ArrayList<>();
        double total = 0;

        for (OrderRequest.OrderItemRequest itemReq : request.getItems()) {
            Product product = productRepository.findById(itemReq.getProductId())
                    .orElseThrow(() -> new ResourceNotFoundException("Product not found: " + itemReq.getProductId()));

            if (product.getStockQuantity() < itemReq.getQuantity()) {
                throw new BusinessException("Insufficient stock for product: " + product.getName()
                        + " (available: " + product.getStockQuantity() + ")");
            }

            // Deduct stock atomically inside the transaction
            product.setStockQuantity(product.getStockQuantity() - itemReq.getQuantity());
            productRepository.save(product);

            OrderItem item = OrderItem.builder()
                    .product(product)
                    .quantity(itemReq.getQuantity())
                    .unitPrice(product.getPrice())
                    .build();
            items.add(item);
            total += product.getPrice() * itemReq.getQuantity();
        }

        Order order = Order.builder()
                .client(client)
                .status(OrderStatus.PENDING)
                .orderDate(new Date())
                .totalAmount(total)
                .build();

        // Link items back to the order before saving
        Order savedOrder = orderRepository.save(order);
        items.forEach(item -> item.setOrder(savedOrder));
        savedOrder.setItems(items);
        orderRepository.save(savedOrder);

        return toDto(savedOrder);
    }

    public List<OrderDto> getAll() {
        return orderRepository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    public List<OrderDto> getByClient(Long clientId) {
        return orderRepository.findByClientId(clientId).stream().map(this::toDto).collect(Collectors.toList());
    }

    public OrderDto updateStatus(Long orderId, OrderStatus status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found: " + orderId));
        order.setStatus(status);
        return toDto(orderRepository.save(order));
    }

    // ── Quotes ──────────────────────────────────────────────────────

    public QuoteDto createQuote(Long clientId, String message) {
        User client = userRepository.findById(clientId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + clientId));

        Quote quote = Quote.builder()
                .client(client)
                .message(message)
                .status(QuoteStatus.PENDING)
                .requestDate(new Date())
                .build();

        return toQuoteDto(quoteRepository.save(quote));
    }

    public List<QuoteDto> getAllQuotes() {
        return quoteRepository.findAll().stream().map(this::toQuoteDto).collect(Collectors.toList());
    }

    public QuoteDto updateQuoteStatus(Long quoteId, QuoteStatus status) {
        Quote quote = quoteRepository.findById(quoteId)
                .orElseThrow(() -> new ResourceNotFoundException("Quote not found: " + quoteId));
        quote.setStatus(status);
        return toQuoteDto(quoteRepository.save(quote));
    }

    // ── Mappers ──────────────────────────────────────────────────────

    private OrderDto toDto(Order o) {
        List<OrderDto.OrderItemDto> itemDtos = o.getItems() == null ? List.of() : o.getItems().stream()
                .map(i -> OrderDto.OrderItemDto.builder()
                        .productId(i.getProduct().getId())
                        .productName(i.getProduct().getName())
                        .quantity(i.getQuantity())
                        .unitPrice(i.getUnitPrice())
                        .build())
                .collect(Collectors.toList());

        return OrderDto.builder()
                .id(o.getId())
                .clientId(o.getClient().getId())
                .clientEmail(o.getClient().getEmail())
                .totalAmount(o.getTotalAmount())
                .status(o.getStatus())
                .orderDate(o.getOrderDate())
                .items(itemDtos)
                .build();
    }

    private QuoteDto toQuoteDto(Quote q) {
        return QuoteDto.builder()
                .id(q.getId())
                .clientId(q.getClient().getId())
                .clientEmail(q.getClient().getEmail())
                .message(q.getMessage())
                .status(q.getStatus())
                .requestDate(q.getRequestDate())
                .build();
    }
}
