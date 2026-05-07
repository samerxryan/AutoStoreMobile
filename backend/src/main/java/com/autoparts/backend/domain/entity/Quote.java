package com.autoparts.backend.domain.entity;

import com.autoparts.backend.domain.enums.QuoteStatus;
import jakarta.persistence.*;
import lombok.*;
import java.util.Date;

@Entity
@Table(name = "quotes")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Quote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id")
    private User client;

    @Column(columnDefinition = "TEXT")
    private String message;

    @Enumerated(EnumType.STRING)
    private QuoteStatus status;

    @Temporal(TemporalType.TIMESTAMP)
    private Date requestDate;
}
