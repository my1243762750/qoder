package com.qoder.minijira.user.service;

import com.qoder.minijira.common.exception.BusinessException;
import com.qoder.minijira.security.JwtTokenProvider;
import com.qoder.minijira.user.dto.AuthResponse;
import com.qoder.minijira.user.dto.LoginRequest;
import com.qoder.minijira.user.dto.RegisterRequest;
import com.qoder.minijira.user.entity.User;
import com.qoder.minijira.user.repository.UserRepository;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final JwtTokenProvider jwtTokenProvider;
    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public AuthService(UserRepository userRepository, JwtTokenProvider jwtTokenProvider) {
        this.userRepository = userRepository;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @Transactional
    public void register(RegisterRequest request) {
        userRepository.findByEmail(request.getEmail()).ifPresent(u -> {
            throw new BusinessException(1000, "Email already registered");
        });
        userRepository.findByUsername(request.getUsername()).ifPresent(u -> {
            throw new BusinessException(1000, "Username already taken");
        });

        User user = new User();
        user.setEmail(request.getEmail());
        user.setUsername(request.getUsername());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setRole("ROLE_USER");

        userRepository.save(user);
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getUsernameOrEmail())
                .orElseGet(() -> userRepository.findByUsername(request.getUsernameOrEmail())
                        .orElseThrow(() -> new BusinessException(2000, "Invalid credentials")));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new BusinessException(2000, "Invalid credentials");
        }

        String subject = user.getId() + ":" + user.getUsername();
        String token = jwtTokenProvider.createToken(subject);
        return new AuthResponse(token);
    }
}
