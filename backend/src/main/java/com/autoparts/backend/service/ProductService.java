package com.autoparts.backend.service;

import com.autoparts.backend.domain.entity.Category;
import com.autoparts.backend.domain.entity.Product;
import com.autoparts.backend.dto.ProductDto;
import com.autoparts.backend.dto.ProductRequest;
import com.autoparts.backend.exception.ResourceNotFoundException;
import com.autoparts.backend.repository.CategoryRepository;
import com.autoparts.backend.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;

    @Value("${app.upload.dir}")
    private String uploadDir;

    public List<ProductDto> findAll() {
        return productRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public ProductDto findById(Long id) {
        return toDto(getOrThrow(id));
    }

    public ProductDto create(ProductRequest request, MultipartFile image) throws IOException {
        Category category = null;
        if (request.getCategoryId() != null) {
            category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Category not found: " + request.getCategoryId()));
        }

        Product product = Product.builder()
                .name(request.getName())
                .description(request.getDescription())
                .price(request.getPrice())
                .stockQuantity(request.getStockQuantity())
                .category(category)
                .build();

        if (image != null && !image.isEmpty()) {
            product.setImageUrl(saveImage(image));
        }

        return toDto(productRepository.save(product));
    }

    public ProductDto update(Long id, ProductRequest request, MultipartFile image) throws IOException {
        Product product = getOrThrow(id);
        product.setName(request.getName());
        product.setDescription(request.getDescription());
        product.setPrice(request.getPrice());
        product.setStockQuantity(request.getStockQuantity());

        if (request.getCategoryId() != null) {
            Category category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Category not found"));
            product.setCategory(category);
        }

        if (image != null && !image.isEmpty()) {
            product.setImageUrl(saveImage(image));
        }

        return toDto(productRepository.save(product));
    }

    public void delete(Long id) {
        productRepository.deleteById(id);
    }

    public List<ProductDto> getLowStock(int threshold) {
        return productRepository.findLowStock(threshold).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    // ── Internal helpers ────────────────────────────────────────────

    private String saveImage(MultipartFile image) throws IOException {
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) Files.createDirectories(uploadPath);

        String filename = UUID.randomUUID() + "_" + image.getOriginalFilename();
        Path filePath = uploadPath.resolve(filename);
        Files.copy(image.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        return "/uploads/" + filename;
    }

    private Product getOrThrow(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found: " + id));
    }

    public ProductDto toDto(Product p) {
        return ProductDto.builder()
                .id(p.getId())
                .name(p.getName())
                .description(p.getDescription())
                .price(p.getPrice())
                .stockQuantity(p.getStockQuantity())
                .imageUrl(p.getImageUrl())
                .categoryId(p.getCategory() != null ? p.getCategory().getId() : null)
                .categoryName(p.getCategory() != null ? p.getCategory().getName() : null)
                .build();
    }
}
