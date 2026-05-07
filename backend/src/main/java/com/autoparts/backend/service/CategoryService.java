package com.autoparts.backend.service;

import com.autoparts.backend.domain.entity.Category;
import com.autoparts.backend.dto.CategoryDto;
import com.autoparts.backend.exception.ResourceNotFoundException;
import com.autoparts.backend.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public List<CategoryDto> findAll() {
        return categoryRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public CategoryDto findById(Long id) {
        return toDto(getOrThrow(id));
    }

    public CategoryDto create(CategoryDto dto) {
        Category cat = Category.builder().name(dto.getName()).build();
        return toDto(categoryRepository.save(cat));
    }

    public CategoryDto update(Long id, CategoryDto dto) {
        Category cat = getOrThrow(id);
        cat.setName(dto.getName());
        return toDto(categoryRepository.save(cat));
    }

    public void delete(Long id) {
        categoryRepository.deleteById(id);
    }

    private Category getOrThrow(Long id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Category not found: " + id));
    }

    public CategoryDto toDto(Category cat) {
        return CategoryDto.builder().id(cat.getId()).name(cat.getName()).build();
    }
}
