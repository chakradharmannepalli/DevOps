# Practice

| **Feature**           | **Bridge**                                    | **Host**                                                                            |
| --------------------- | --------------------------------------------- | ----------------------------------------------------------------------------------- |
| **IP Address**        | Container gets its own IP in a bridge network | Container shares the host's IP address                                              |
| **Network Isolation** | Isolated network for containers               | No isolation, shares the host's network                                             |
| **Performance**       | Slightly lower due to NAT overhead            | Better performance (no NAT overhead)                                                |
| **Use Case**          | General-purpose networking for containers     | Performance-critical applications or when direct access to host network is required |
