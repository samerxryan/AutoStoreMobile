package com.autoparts.backend.config;

import com.autoparts.backend.domain.entity.User;
import com.autoparts.backend.domain.enums.Role;
import com.autoparts.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        System.out.println("--- Starting Data Seeding ---");
        var userOpt = userRepository.findByEmail("admin@autoparts.tn");
        if (userOpt.isPresent()) {
            User existing = userOpt.get();
            System.out.println("Admin user exists, updating role and password...");
            existing.setRole(Role.ADMIN);
            existing.setPassword(passwordEncoder.encode("admin123"));
            userRepository.save(existing);
            System.out.println("====== ADMIN ACCOUNT UPDATED: admin@autoparts.tn / admin123 ======");
        } else {
            System.out.println("Admin user NOT found, creating new...");
            User admin = User.builder()
                    .email("admin@autoparts.tn")
                    .password(passwordEncoder.encode("admin123"))
                    .firstName("Admin")
                    .lastName("AutoParts")
                    .phone("+216 00 000 000")
                    .role(Role.ADMIN)
                    .build();
            userRepository.save(admin);
            System.out.println("====== ADMIN ACCOUNT CREATED: admin@autoparts.tn / admin123 ======");
        }
        System.out.println("--- Data Seeding Finished ---");
    }
}
