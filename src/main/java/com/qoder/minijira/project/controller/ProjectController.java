package com.qoder.minijira.project.controller;

import com.qoder.minijira.common.api.ApiResponse;
import com.qoder.minijira.project.dto.ProjectCreateRequest;
import com.qoder.minijira.project.dto.ProjectResponse;
import com.qoder.minijira.project.service.ProjectService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/projects")
public class ProjectController {

    private final ProjectService projectService;

    public ProjectController(ProjectService projectService) {
        this.projectService = projectService;
    }

    @PostMapping
    public ApiResponse<ProjectResponse> createProject(@Valid @RequestBody ProjectCreateRequest request) {
        ProjectResponse response = projectService.createProject(request);
        return ApiResponse.success(response);
    }

    @GetMapping
    public ApiResponse<List<ProjectResponse>> listMyProjects() {
        List<ProjectResponse> projects = projectService.listMyProjects();
        return ApiResponse.success(projects);
    }
}
