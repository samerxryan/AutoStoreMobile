package com.autoparts.backend.repository;

import com.autoparts.backend.domain.entity.Order;
import com.autoparts.backend.domain.enums.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Date;
import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {

    List<Order> findByClientId(Long clientId);

    long countByStatus(OrderStatus status);

    @Query("SELECT SUM(o.totalAmount) FROM Order o WHERE o.status != 'CANCELLED' AND o.orderDate >= :start AND o.orderDate < :end")
    Double sumRevenueByDateRange(@Param("start") Date start, @Param("end") Date end);

    @Query(value = """
            SELECT TO_CHAR(o.order_date, 'YYYY-MM-DD') AS day, SUM(o.total_amount) AS revenue
            FROM orders o
            WHERE o.status != 'CANCELLED'
              AND o.order_date >= :start
            GROUP BY day
            ORDER BY day ASC
            """, nativeQuery = true)
    List<Object[]> getDailyRevenue(@Param("start") Date start);

    @Query(value = """
            SELECT p.name, SUM(oi.quantity) AS total_sold
            FROM order_items oi
            JOIN products p ON p.id = oi.product_id
            JOIN orders o ON o.id = oi.order_id
            WHERE o.status != 'CANCELLED'
            GROUP BY p.id, p.name
            ORDER BY total_sold DESC
            LIMIT 10
            """, nativeQuery = true)
    List<Object[]> getTopProducts();
}
