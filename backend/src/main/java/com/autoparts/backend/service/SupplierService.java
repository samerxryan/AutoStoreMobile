package com.autoparts.backend.service;

import com.autoparts.backend.domain.entity.Supplier;
import com.autoparts.backend.dto.SupplierDto;
import com.autoparts.backend.exception.ResourceNotFoundException;
import com.autoparts.backend.repository.SupplierRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SupplierService {

    private final SupplierRepository supplierRepository;

    public List<SupplierDto> findAll() {
        return supplierRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public SupplierDto findById(Long id) {
        return toDto(getOrThrow(id));
    }

    public SupplierDto create(SupplierDto dto) {
        Supplier s = Supplier.builder()
                .name(dto.getName())
                .contactInfo(dto.getContactInfo())
                .build();
        return toDto(supplierRepository.save(s));
    }

    public SupplierDto update(Long id, SupplierDto dto) {
        Supplier s = getOrThrow(id);
        s.setName(dto.getName());
        s.setContactInfo(dto.getContactInfo());
        return toDto(supplierRepository.save(s));
    }

    public void delete(Long id) {
        supplierRepository.deleteById(id);
    }

    private Supplier getOrThrow(Long id) {
        return supplierRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Supplier not found: " + id));
    }

    private SupplierDto toDto(Supplier s) {
        return SupplierDto.builder()
                .id(s.getId())
                .name(s.getName())
                .contactInfo(s.getContactInfo())
                .build();
    }
}
