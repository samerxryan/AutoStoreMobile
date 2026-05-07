package com.autoparts.backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Table(name = "suppliers")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Supplier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    private String contactInfo;

    @OneToMany(mappedBy = "supplier", cascade = CascadeType.ALL)
    private List<Purchase> purchases;
}
