package com.qoder.minijira.issue.controller;

import com.qoder.minijira.common.api.ApiResponse;
import com.qoder.minijira.issue.dto.IssueResponse;
import com.qoder.minijira.issue.dto.IssueUpdateRequest;
import com.qoder.minijira.issue.service.IssueService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/issues")
public class IssueResourceController {

    private final IssueService issueService;

    public IssueResourceController(IssueService issueService) {
        this.issueService = issueService;
    }

    @PutMapping("/{id}")
    public ApiResponse<IssueResponse> updateIssue(@PathVariable Long id, @RequestBody IssueUpdateRequest request) {
        IssueResponse response = issueService.updateIssue(id, request);
        return ApiResponse.success(response);
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteIssue(@PathVariable Long id) {
        issueService.deleteIssue(id);
        return ApiResponse.success(null);
    }
}
