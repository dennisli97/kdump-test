#!/usr/bin/env bash

# Copyright (C) 2016 Song Qihan<qsong@redhat.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

. ../lib/kdump.sh
. ../lib/crash.sh
. ../lib/log.sh

C_REBOOT="./C_REBOOT"

crash_oops_BUG()
{
    if [[ ! -f "${C_REBOOT}" ]]; then
        kdump_prepare
        kdump_restart
        make_module "oops_BUG"
        insmod oops_BUG/oops_BUG.ko || log_error "Failed to insmod module"

        touch "${C_REBOOT}"
        log_info "Boot to 2nd kernel"
        sync

        # workaround for bug 810201
        echo 1 > /proc/sys/kernel/panic_on_opps

        echo 1 > /proc/crasher
        if [[ $? -ne 0 ]]; then
            log_error "Error to trigger opps_BUG"
        fi

        #Stop here
        sleep 3600

        log_error "Error after sleeping 3600, it still alive"
    else
        rm -f "${C_REBOOT}"
    fi
    check_vmcore_file
    ready_to_exit
}

log_info "Start"
crash_oops_BUG
