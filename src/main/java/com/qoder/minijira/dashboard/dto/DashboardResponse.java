package com.qoder.minijira.dashboard.dto;

public class DashboardResponse {

    private long totalProjects;
    private long totalIssues;
    private long myIssues;

    public DashboardResponse(long totalProjects, long totalIssues, long myIssues) {
        this.totalProjects = totalProjects;
        this.totalIssues = totalIssues;
        this.myIssues = myIssues;
    }

    public long getTotalProjects() {
        return totalProjects;
    }

    public void setTotalProjects(long totalProjects) {
        this.totalProjects = totalProjects;
    }

    public long getTotalIssues() {
        return totalIssues;
    }

    public void setTotalIssues(long totalIssues) {
        this.totalIssues = totalIssues;
    }

    public long getMyIssues() {
        return myIssues;
    }

    public void setMyIssues(long myIssues) {
        this.myIssues = myIssues;
    }
}
