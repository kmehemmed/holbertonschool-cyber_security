Future Mitigations
Introduction
Analyzing web application and system logs (auth.log, dmesg) allows an organization to reconstruct how an attack unfolded, identify which accounts and services were abused, and understand which vulnerabilities were exploited. The findings below come directly from the log analysis performed in this project (tasks 0-5) and are used here to build a concrete incident report, an implementation plan, and an ongoing monitoring protocol.

Incident Report
Summary
The target system (app-1), running Ubuntu Linux, kernel 2.6.24-26-server, was compromised through a sustained SSH brute-force campaign.

Key Findings
Attack vector: All malicious activity originated from the sshd service (OpenSSH). Log analysis of auth.log showed tens of thousands of Failed password and Invalid user entries tied to pam_unix(sshd:auth), confirming SSH as the sole entry point used by the attackers.
Compromised account: The root account was identified as compromised. It received repeated failed login attempts followed by a successful Accepted password event from the same source IP addresses, a clear brute-force-then-success pattern.
Scale of the attack: 18 distinct IP addresses (18 separate attackers) successfully authenticated as the compromised account, indicating either a distributed brute-force campaign or credential reuse/sharing across multiple attacking hosts.
Post-compromise activity:
The attackers (or a user acting through the compromised root session) modified the system firewall, adding 6 new iptables -A rules to the INPUT chain, opening additional ports (including SSH on a non-standard port, DNS, and port 113/identd). This is a classic persistence technique to keep remote access available even if the original vector is closed.
Multiple new local user accounts were created on the system (e.g. Aphelios, Debian-exim, Fido, Jax, Nidalee, Senna, dhg, messagebus, mysql, packet, sshd). While several of these are legitimate system/service accounts created by package installation, the presence of non-standard named accounts alongside the compromise timeline warrants individual review, since rogue accounts are a common persistence mechanism.
Impact
Full root-level access was obtained by unauthorized external parties.
Firewall configuration was altered, potentially widening the system's attack surface and/or creating a persistent backdoor path.
Integrity of local accounts and their privileges can no longer be fully trusted without a manual audit.
Implementation Plan
A step-by-step plan to remediate the incident and reduce the risk of recurrence:

Contain the incident

Disconnect or firewall off app-1 from untrusted networks while the investigation is ongoing.
Rotate the root password and all credentials that may have been reachable from the compromised session.
Eradicate persistence mechanisms

Review every account listed in task 5 against the official provisioning records; disable or delete any account that cannot be attributed to a legitimate process or administrator.
Review the 6 iptables -A rules added during the incident window and remove any rule that was not explicitly approved by change management.
Check cron, systemd timers, ~/.ssh/authorized_keys, and /etc/passwd//etc/shadow for additional backdoors left by the attacker.
Harden SSH access

Disable direct root SSH login (PermitRootLogin no).
Enforce key-based authentication only (PasswordAuthentication no).
Move SSH off the default port only as a minor deterrent, not as a primary control, and pair it with fail2ban or an equivalent to auto-block IPs after repeated failures.
Enforce a strict account lockout / rate-limit policy on authentication failures.
Restrict firewall/administrative changes

Require multi-person approval (change management) for any iptables/ufw modification.
Move to a version-controlled firewall configuration so every rule change is logged, reviewed, and reversible.
Patch and update

Upgrade the kernel and OS packages; the identified kernel (2.6.24, released circa 2009) is far past end-of-life and carries many known, unpatched vulnerabilities.
Rebuild if in doubt

Given the scope of the compromise (root access, unknown accounts, altered firewall), consider rebuilding the host from a known-good image rather than fully trusting in-place remediation.
Monitoring Protocol
Guidelines to continuously evaluate whether the mitigations above remain effective:

Centralize and retain logs

Forward auth.log, dmesg, firewall logs, and authentication events to a central log server/SIEM with a minimum 90-day retention so historical patterns (like the ones found in this project) can always be reconstructed.
Automate the detections used in this investigation

Schedule the scripts built in this project (0-service.sh through 5-users.sh) — or equivalent SIEM alert rules — to run on a recurring basis (e.g. daily) against fresh logs, and alert when:
The failed/invalid SSH login count spikes above a defined baseline.
A Failed password sequence for a given account is followed by an Accepted password from the same or a related IP.
The number of distinct successful-login IP addresses for a single account increases abnormally in a short window.
A new iptables/ufw rule is added outside of an approved change window.
A new local user account is created.
Review access and firewall changes

Weekly review of all accounts against the authoritative list of approved accounts.
Weekly diff of the live firewall ruleset against the version-controlled baseline.
Test the controls

Periodically run internal brute-force simulations against a staging environment to confirm lockout/rate-limiting and alerting still trigger as expected.
Include SSH hardening and firewall-change-control checks in recurring vulnerability scans and penetration tests.
Continuous improvement

Feed findings from each monitoring cycle and any future incident back into the detection rules and this mitigation plan, keeping it a living document rather than a one-time report.
