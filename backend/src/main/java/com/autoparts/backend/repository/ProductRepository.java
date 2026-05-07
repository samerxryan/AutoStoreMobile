package com.autoparts.backend.repository;

import com.autoparts.backend.domain.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Long> {

    @Query("SELECT p FROM Product p WHERE p.stockQuantity <= :threshold")
    List<Product> findLowStock(int threshold);

    long countByStockQuantityLessThanEqual(int threshold);
}
