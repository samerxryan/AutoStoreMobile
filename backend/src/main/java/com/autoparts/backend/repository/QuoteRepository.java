package com.autoparts.backend.repository;

import com.autoparts.backend.domain.entity.Quote;
import org.springframework.data.jpa.repository.JpaRepository;

public interface QuoteRepository extends JpaRepository<Quote, Long> {
}
