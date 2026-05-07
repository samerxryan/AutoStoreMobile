package com.autoparts.backend.service;

import com.autoparts.backend.domain.entity.User;
import com.autoparts.backend.domain.enums.Role;
import com.autoparts.backend.dto.AuthRequest;
import com.autoparts.backend.dto.AuthResponse;
import com.autoparts.backend.dto.RegisterRequest;
import com.autoparts.backend.repository.UserRepository;
import com.autoparts.backend.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository repository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    public AuthResponse register(RegisterRequest request) {
        if(repository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }
        var user = User.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .role(Role.CLIENT) // default to client registration
                .build();
        repository.save(user);
        var extraClaims = new java.util.HashMap<String, Object>();
        extraClaims.put("authorities", user.getAuthorities().stream()
                .map(org.springframework.security.core.GrantedAuthority::getAuthority)
                .toList());
        var jwtToken = jwtService.generateToken(extraClaims, user);
        return AuthResponse.builder()
                .token(jwtToken)
                .build();
    }

    public AuthResponse authenticate(AuthRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );
        var user = repository.findByEmail(request.getEmail())
                .orElseThrow();
        var extraClaims = new java.util.HashMap<String, Object>();
        extraClaims.put("authorities", user.getAuthorities().stream()
                .map(org.springframework.security.core.GrantedAuthority::getAuthority)
                .toList());
        var jwtToken = jwtService.generateToken(extraClaims, user);
        return AuthResponse.builder()
                .token(jwtToken)
                .build();
    }
}
