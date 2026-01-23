package com.qoder.minijira.project.service;

import com.qoder.minijira.common.exception.BusinessException;
import com.qoder.minijira.project.dto.ProjectCreateRequest;
import com.qoder.minijira.project.dto.ProjectResponse;
import com.qoder.minijira.project.dto.ProjectUpdateRequest;
import com.qoder.minijira.project.entity.Project;
import com.qoder.minijira.project.repository.ProjectRepository;
import com.qoder.minijira.user.entity.User;
import com.qoder.minijira.user.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProjectService {

    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;

    public ProjectService(ProjectRepository projectRepository, UserRepository userRepository) {
        this.projectRepository = projectRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public ProjectResponse createProject(ProjectCreateRequest request) {
        User currentUser = getCurrentUser();

        Project project = new Project();
        project.setName(request.getName());
        project.setDescription(request.getDescription());
        project.setOwner(currentUser);

        Project saved = projectRepository.save(project);
        return new ProjectResponse(saved.getId(), saved.getName(), saved.getDescription());
    }

    public List<ProjectResponse> listMyProjects() {
        User currentUser = getCurrentUser();
        List<Project> projects = projectRepository.findByOwner(currentUser);
        return projects.stream()
                .map(p -> new ProjectResponse(p.getId(), p.getName(), p.getDescription()))
                .collect(Collectors.toList());
    }

    public ProjectResponse getProject(Long id) {
        Project project = projectRepository.findById(id)
                .orElseThrow(() -> new BusinessException(3000, "Project not found"));
        // In a real app, check permission here
        return new ProjectResponse(project.getId(), project.getName(), project.getDescription());
    }

    @Transactional
    public ProjectResponse updateProject(Long id, ProjectUpdateRequest request) {
        Project project = projectRepository.findById(id)
                .orElseThrow(() -> new BusinessException(3000, "Project not found"));
        
        User currentUser = getCurrentUser();
        // Allow owner or admin? For now just owner check if we want strictness, or just allow logged in users for demo
        if (!project.getOwner().getId().equals(currentUser.getId())) {
             throw new BusinessException(403, "Not authorized to update this project");
        }

        project.setName(request.getName());
        project.setDescription(request.getDescription());
        
        Project saved = projectRepository.save(project);
        return new ProjectResponse(saved.getId(), saved.getName(), saved.getDescription());
    }

    @Transactional
    public void deleteProject(Long id) {
        Project project = projectRepository.findById(id)
                .orElseThrow(() -> new BusinessException(3000, "Project not found"));
        // Check permission
        User currentUser = getCurrentUser();
        if (!project.getOwner().getId().equals(currentUser.getId())) {
             throw new BusinessException(403, "Not authorized to delete this project");
        }
        projectRepository.delete(project);
    }

    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new BusinessException(2000, "Not authenticated");
        }
        String principal = authentication.getName();
        String username = principal.contains(":") ? principal.split(":", 2)[1] : principal;
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new BusinessException(2000, "User not found"));
    }
}
