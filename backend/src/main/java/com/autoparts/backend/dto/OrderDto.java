package com.autoparts.backend.dto;

import com.autoparts.backend.domain.enums.OrderStatus;
import lombok.*;
import java.util.Date;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderDto {
    private Long id;
    private Long clientId;
    private String clientEmail;
    private Double totalAmount;
    private OrderStatus status;
    private Date orderDate;
    private List<OrderItemDto> items;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OrderItemDto {
        private Long productId;
        private String productName;
        private Integer quantity;
        private Double unitPrice;
    }
}
