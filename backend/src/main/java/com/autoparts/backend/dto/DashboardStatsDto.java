package com.autoparts.backend.dto;

import lombok.*;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStatsDto {
    private Double todayRevenue;
    private Double monthRevenue;
    private Long totalOrders;
    private Long pendingOrders;
    private Long totalProducts;
    private Long lowStockProducts;
    private List<DailyStat> dailyRevenue;
    private List<TopProduct> topProducts;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DailyStat {
        private String date;
        private Double revenue;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TopProduct {
        private String productName;
        private Long totalSold;
    }
}
