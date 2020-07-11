# Security-Based Limitations

The following are areas that are currently **not automated**.  It may be
possible to use `ansible-vault` to assist in automation, but for now I am
playing it safe and swapping some convenience for added security.

## Password-based authentication to web accounts is not automated

For example, you must log into your Firefox account manually.  A quick web
search turned up the following GitHub repos for Firefox configuration, which
may or may not include login capabilities (I haven't looked closely):

- <https://github.com/juju4/ansible-firefox-config>
- <https://github.com/alzadude/ansible-firefox>

## SSH-based authentication to web accounts is not automated

### New SSH keys must be generated for new user accounts on new devices

It is my opinion that private SSH keys should be tied to individual user
accounts on specific devices rather than shared between users and/or devices.
This provides better auditability, and makes access easier to revoke when
users and/or devices no longer require access to a service.  Adhering to this
rule means that private SSH keys become quite decentralized; therefore, no
convenience or security will be gained in storing and retrieving private SSH
keys from a central keystore.

I also believe that SSH keys should be password-protected.  This means that
when they are generated, a password should be supplied.  For now, this is an
interactive process.

See the following web pages for ideas on automating SSH key generation for
everything but the password prompt:

- <https://www.codesandnotes.be/2020/01/13/generate-ssh-keys-using-ansible/>
- <https://docs.ansible.com/ansible/latest/user_guide/playbooks_prompts.html>
- <https://stackoverflow.com/questions/45100377/vars-prompt-in-playbooks>
- <https://stackoverflow.com/questions/30192490/include-tasks-from-another-role-in-ansible-playbook>

### When provisioning remote hosts, SSH keys can be forwarded instead

One exception to the rule stated in the previous section is SSH agent key
forwarding, where a user accesses a remote host to perform SSH operations using
the keys tied to their account on the local host.  In my opinion, this provides
better auditability than using a different key on the remote host, since the
SSH operations can be traced to their true origin.  This also increases
manageability by reducing key sprawl.
