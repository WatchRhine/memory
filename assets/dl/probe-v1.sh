#!/usr/bin/env bash

set -u

STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
HOSTNAME_SAFE="$(hostname 2>/dev/null || echo unknown)"

echo "=============================================="
echo "  HOST-IP REPORT  "
echo "  time : $STAMP"
echo "  host : $HOSTNAME_SAFE"
echo "----------------------------------------------"

if command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -Command '
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        $cfg = Get-NetIPConfiguration |
            Where-Object { $_.IPv4DefaultGateway -ne $null } |
            Select-Object -First 1
        if ($cfg) {
            "  HOST-IP : {0}" -f $cfg.IPv4Address.IPAddress
            "  iface   : {0}" -f $cfg.InterfaceAlias
        } else {
            "  HOST-IP : <not found>"
        }
    ' 2>/dev/null

    echo "----------------------------------------------"
    echo "  all non-loopback IPv4:"
    powershell.exe -NoProfile -Command '
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        Get-NetIPAddress -AddressFamily IPv4 |
            Where-Object {
                $_.IPAddress -notlike "127.*" -and
                $_.IPAddress -notlike "169.254.*" -and
                $_.IPAddress -ne "0.0.0.0"
            } |
            Sort-Object InterfaceIndex |
            ForEach-Object { "    {0,-16} {1}" -f $_.IPAddress, $_.InterfaceAlias }
    ' 2>/dev/null
else
    ipconfig | grep -i "IPv4" | sed 's/^[[:space:]]*/  /'
fi

echo "=============================================="
