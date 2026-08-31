package trivy

# Ignore vulnerabilities reported against the external-dns module itself:
# this fork is built from upstream releases with local patches, the binary
# carries a non-release version, so scanners match every external-dns CVE
# regardless of the fixes actually present. external-dns CVEs are handled
# by rebasing on upstream.
default ignore = false

ignore {
	startswith(input.PkgName, "sigs.k8s.io/external-dns")
}
