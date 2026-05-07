package com.autoparts.backend.controller;

import com.autoparts.backend.dto.SupplierDto;
import com.autoparts.backend.service.SupplierService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/suppliers")
@RequiredArgsConstructor
public class SupplierController {

    private final SupplierService supplierService;

    @GetMapping
    public ResponseEntity<List<SupplierDto>> getAll() {
        return ResponseEntity.ok(supplierService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<SupplierDto> getById(@PathVariable Long id) {
        return ResponseEntity.ok(supplierService.findById(id));
    }

    @PostMapping
    public ResponseEntity<SupplierDto> create(@RequestBody SupplierDto dto) {
        return ResponseEntity.ok(supplierService.create(dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<SupplierDto> update(@PathVariable Long id, @RequestBody SupplierDto dto) {
        return ResponseEntity.ok(supplierService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        supplierService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
