package com.autoparts.backend.controller;

import com.autoparts.backend.dto.ProductDto;
import com.autoparts.backend.dto.ProductRequest;
import com.autoparts.backend.service.ProductService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @GetMapping
    public ResponseEntity<List<ProductDto>> getAll() {
        return ResponseEntity.ok(productService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductDto> getById(@PathVariable Long id) {
        return ResponseEntity.ok(productService.findById(id));
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ProductDto> create(
            @Valid @RequestPart("product") ProductRequest request,
            @RequestPart(value = "image", required = false) MultipartFile image
    ) throws IOException {
        return ResponseEntity.ok(productService.create(request, image));
    }

    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ProductDto> update(
            @PathVariable Long id,
            @Valid @RequestPart("product") ProductRequest request,
            @RequestPart(value = "image", required = false) MultipartFile image
    ) throws IOException {
        return ResponseEntity.ok(productService.update(id, request, image));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        productService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/low-stock")
    public ResponseEntity<List<ProductDto>> getLowStock(
            @RequestParam(defaultValue = "5") int threshold) {
        return ResponseEntity.ok(productService.getLowStock(threshold));
    }
}
