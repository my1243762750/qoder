package com.qoder.minijira.issue.repository;

import com.qoder.minijira.issue.entity.Issue;
import com.qoder.minijira.project.entity.Project;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface IssueRepository extends JpaRepository<Issue, Long> {

    List<Issue> findByProject(Project project);

    long countByProjectOwnerId(Long ownerId);

    long countByAssigneeId(Long assigneeId);
}
