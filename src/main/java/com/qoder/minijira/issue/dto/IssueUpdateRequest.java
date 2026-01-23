package com.qoder.minijira.issue.dto;

public class IssueUpdateRequest {
    private String status;
    private String priority;

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }
}
