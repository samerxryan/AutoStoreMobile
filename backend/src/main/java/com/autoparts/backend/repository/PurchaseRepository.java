package com.autoparts.backend.repository;

import com.autoparts.backend.domain.entity.Purchase;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PurchaseRepository extends JpaRepository<Purchase, Long> {
}
