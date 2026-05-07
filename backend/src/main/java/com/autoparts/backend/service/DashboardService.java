package com.autoparts.backend.service;

import com.autoparts.backend.domain.enums.OrderStatus;
import com.autoparts.backend.dto.DashboardStatsDto;
import com.autoparts.backend.repository.OrderRepository;
import com.autoparts.backend.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.*;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;

    public DashboardStatsDto getStats() {
        Date now = new Date();
        Date startOfToday = Date.from(LocalDate.now().atStartOfDay(ZoneId.systemDefault()).toInstant());
        Date startOfTomorrow = Date.from(LocalDate.now().plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant());
        Date startOfMonth = Date.from(LocalDate.now().withDayOfMonth(1).atStartOfDay(ZoneId.systemDefault()).toInstant());
        Date thirtyDaysAgo = Date.from(Instant.now().minus(java.time.Duration.ofDays(30)));

        // Revenue KPIs
        Double todayRevenue = orderRepository.sumRevenueByDateRange(startOfToday, startOfTomorrow);
        Double monthRevenue = orderRepository.sumRevenueByDateRange(startOfMonth, startOfTomorrow);

        // Order count KPIs
        long totalOrders = orderRepository.count();
        long pendingOrders = orderRepository.countByStatus(OrderStatus.PENDING);

        // Product KPIs
        long totalProducts = productRepository.count();
        long lowStockProducts = productRepository.countByStockQuantityLessThanEqual(5);

        // Daily revenue for last 30 days
        List<DashboardStatsDto.DailyStat> dailyRevenue = orderRepository.getDailyRevenue(thirtyDaysAgo)
                .stream()
                .map(row -> DashboardStatsDto.DailyStat.builder()
                        .date(row[0].toString())
                        .revenue(((Number) row[1]).doubleValue())
                        .build())
                .collect(Collectors.toList());

        // Top 10 sold products
        List<DashboardStatsDto.TopProduct> topProducts = orderRepository.getTopProducts()
                .stream()
                .map(row -> DashboardStatsDto.TopProduct.builder()
                        .productName(row[0].toString())
                        .totalSold(((Number) row[1]).longValue())
                        .build())
                .collect(Collectors.toList());

        return DashboardStatsDto.builder()
                .todayRevenue(todayRevenue != null ? todayRevenue : 0.0)
                .monthRevenue(monthRevenue != null ? monthRevenue : 0.0)
                .totalOrders(totalOrders)
                .pendingOrders(pendingOrders)
                .totalProducts(totalProducts)
                .lowStockProducts(lowStockProducts)
                .dailyRevenue(dailyRevenue)
                .topProducts(topProducts)
                .build();
    }
}
