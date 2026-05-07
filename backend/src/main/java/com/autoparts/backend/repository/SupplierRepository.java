package com.autoparts.backend.repository;

import com.autoparts.backend.domain.entity.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SupplierRepository extends JpaRepository<Supplier, Long> {
}
