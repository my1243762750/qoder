package com.qoder.minijira.issue.service;

import com.qoder.minijira.common.exception.BusinessException;
import com.qoder.minijira.issue.dto.IssueCreateRequest;
import com.qoder.minijira.issue.dto.IssueResponse;
import com.qoder.minijira.issue.entity.Issue;
import com.qoder.minijira.issue.entity.IssuePriority;
import com.qoder.minijira.issue.entity.IssueStatus;
import com.qoder.minijira.issue.repository.IssueRepository;
import com.qoder.minijira.project.entity.Project;
import com.qoder.minijira.project.repository.ProjectRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class IssueService {

    private final IssueRepository issueRepository;
    private final ProjectRepository projectRepository;

    public IssueService(IssueRepository issueRepository, ProjectRepository projectRepository) {
        this.issueRepository = issueRepository;
        this.projectRepository = projectRepository;
    }

    @Transactional
    public IssueResponse createIssue(Long projectId, IssueCreateRequest request) {
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new BusinessException(3000, "Project not found"));

        Issue issue = new Issue();
        issue.setProject(project);
        issue.setTitle(request.getTitle());
        issue.setDescription(request.getDescription());
        issue.setStatus(IssueStatus.OPEN);
        issue.setPriority(IssuePriority.valueOf(request.getPriority().toUpperCase()));

        Issue saved = issueRepository.save(issue);
        return toResponse(saved);
    }

    public List<IssueResponse> listIssues(Long projectId) {
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new BusinessException(3000, "Project not found"));
        List<Issue> issues = issueRepository.findByProject(project);
        return issues.stream().map(this::toResponse).collect(Collectors.toList());
    }

    private IssueResponse toResponse(Issue issue) {
        return new IssueResponse(
                issue.getId(),
                issue.getTitle(),
                issue.getDescription(),
                issue.getStatus(),
                issue.getPriority()
        );
    }
}
