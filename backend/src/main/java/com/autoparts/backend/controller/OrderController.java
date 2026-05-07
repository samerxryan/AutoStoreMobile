package com.autoparts.backend.controller;

import com.autoparts.backend.domain.enums.OrderStatus;
import com.autoparts.backend.domain.enums.QuoteStatus;
import com.autoparts.backend.dto.OrderDto;
import com.autoparts.backend.dto.OrderRequest;
import com.autoparts.backend.dto.QuoteDto;
import com.autoparts.backend.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    // Client places an order
    @PostMapping
    public ResponseEntity<OrderDto> placeOrder(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody OrderRequest request
    ) {
        com.autoparts.backend.domain.entity.User user =
                (com.autoparts.backend.domain.entity.User) userDetails;
        return ResponseEntity.ok(orderService.placeOrder(user.getId(), request));
    }

    // Client views their own order history
    @GetMapping("/my")
    public ResponseEntity<List<OrderDto>> myOrders(
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        com.autoparts.backend.domain.entity.User user =
                (com.autoparts.backend.domain.entity.User) userDetails;
        return ResponseEntity.ok(orderService.getByClient(user.getId()));
    }

    // Admin: view all orders
    @GetMapping
    public ResponseEntity<List<OrderDto>> getAll() {
        return ResponseEntity.ok(orderService.getAll());
    }

    // Admin: update order status
    @PatchMapping("/{id}/status")
    public ResponseEntity<OrderDto> updateStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> body
    ) {
        OrderStatus status = OrderStatus.valueOf(body.get("status").toUpperCase());
        return ResponseEntity.ok(orderService.updateStatus(id, status));
    }

    // Client: submit a quote request
    @PostMapping("/quotes")
    public ResponseEntity<QuoteDto> requestQuote(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody Map<String, String> body
    ) {
        com.autoparts.backend.domain.entity.User user =
                (com.autoparts.backend.domain.entity.User) userDetails;
        return ResponseEntity.ok(orderService.createQuote(user.getId(), body.get("message")));
    }

    // Admin: view all quotes
    @GetMapping("/quotes")
    public ResponseEntity<List<QuoteDto>> getAllQuotes() {
        return ResponseEntity.ok(orderService.getAllQuotes());
    }

    // Admin: approve or reject a quote
    @PatchMapping("/quotes/{id}/status")
    public ResponseEntity<QuoteDto> updateQuoteStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> body
    ) {
        QuoteStatus status = QuoteStatus.valueOf(body.get("status").toUpperCase());
        return ResponseEntity.ok(orderService.updateQuoteStatus(id, status));
    }
}
