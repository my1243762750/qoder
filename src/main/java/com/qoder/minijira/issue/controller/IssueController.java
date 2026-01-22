package com.qoder.minijira.issue.controller;

import com.qoder.minijira.common.api.ApiResponse;
import com.qoder.minijira.issue.dto.IssueCreateRequest;
import com.qoder.minijira.issue.dto.IssueResponse;
import com.qoder.minijira.issue.service.IssueService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/projects/{projectId}/issues")
public class IssueController {

    private final IssueService issueService;

    public IssueController(IssueService issueService) {
        this.issueService = issueService;
    }

    @PostMapping
    public ApiResponse<IssueResponse> createIssue(@PathVariable Long projectId,
                                                   @Valid @RequestBody IssueCreateRequest request) {
        IssueResponse response = issueService.createIssue(projectId, request);
        return ApiResponse.success(response);
    }

    @GetMapping
    public ApiResponse<List<IssueResponse>> listIssues(@PathVariable Long projectId) {
        List<IssueResponse> issues = issueService.listIssues(projectId);
        return ApiResponse.success(issues);
    }
}
