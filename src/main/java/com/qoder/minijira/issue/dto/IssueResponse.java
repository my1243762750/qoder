package com.qoder.minijira.issue.dto;

import com.qoder.minijira.issue.entity.IssuePriority;
import com.qoder.minijira.issue.entity.IssueStatus;

public class IssueResponse {

    private Long id;
    private String title;
    private String description;
    private IssueStatus status;
    private IssuePriority priority;

    public IssueResponse(Long id, String title, String description, IssueStatus status, IssuePriority priority) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.status = status;
        this.priority = priority;
    }

    public Long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public IssueStatus getStatus() {
        return status;
    }

    public IssuePriority getPriority() {
        return priority;
    }
}
