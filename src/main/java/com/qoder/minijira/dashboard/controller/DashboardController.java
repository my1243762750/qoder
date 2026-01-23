package com.qoder.minijira.dashboard.controller;

import com.qoder.minijira.common.api.ApiResponse;
import com.qoder.minijira.dashboard.dto.DashboardResponse;
import com.qoder.minijira.issue.repository.IssueRepository;
import com.qoder.minijira.project.repository.ProjectRepository;
import com.qoder.minijira.user.entity.User;
import com.qoder.minijira.user.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    private final ProjectRepository projectRepository;
    private final IssueRepository issueRepository;
    private final UserRepository userRepository;

    public DashboardController(ProjectRepository projectRepository, IssueRepository issueRepository, UserRepository userRepository) {
        this.projectRepository = projectRepository;
        this.issueRepository = issueRepository;
        this.userRepository = userRepository;
    }

    @GetMapping("/stats")
    public ApiResponse<DashboardResponse> getStats() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentPrincipalName = authentication.getName(); // id:username
        Long userId = Long.parseLong(currentPrincipalName.split(":")[0]);
        User currentUser = userRepository.findById(userId).orElseThrow();

        long totalProjects = projectRepository.countByOwner(currentUser);
        long totalIssues = issueRepository.countByProjectOwnerId(userId);
        long myIssues = issueRepository.countByAssigneeId(userId);

        return ApiResponse.success(new DashboardResponse(totalProjects, totalIssues, myIssues));
    }
}
