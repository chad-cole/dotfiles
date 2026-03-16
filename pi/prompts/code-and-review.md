---
name: code-and-review
description: Implement a feature with coder, then review with style-reviewer. Usage: /code-and-review <task>
---

Use a chain of agents to implement and review:

1. First, use **coder** to implement the task: {args}
2. Then, use **style-reviewer** to review the changes from the previous step: Review the code changes from the coder. Here are the details: {previous}
