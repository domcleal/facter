# memory.rb
# Additional Facts for memory/swap usage
#
# Copyright (C) 2006 Mooter Media Ltd
# Author: Matthew Palmer <matt@solutionsfirst.com.au>
#
#
require 'facter/util/memory'

if Facter.value(:kernel) == "Linux"
    {   :MemorySize => "MemTotal",
        :MemoryFree => "MemFree",
        :SwapSize   => "SwapTotal",
        :SwapFree   => "SwapFree"
    }.each do |fact, name|
        meminfo = Facter::Memory.meminfo_number(name)
        Facter::Memory::add_memfacts(fact, meminfo, :linux)
    end
end

if Facter.value(:kernel) == "AIX" and Facter.value(:id) == "root"
    swap = Facter::Util::Resolution.exec('swap -l')
    swapfree, swaptotal = 0, 0
    swap.each do |dev|
      if dev =~ /^\/\S+\s.*\s+(\S+)MB\s+(\S+)MB/
        swaptotal += $1.to_i
        swapfree  += $2.to_i
      end 
    end 
 
    meminfo = Facter::Memory.scale_number(swaptotal.to_f,"MB")
    Facter::Memory::add_memfacts("SwapSize", meminfo, :aix)

    meminfo = Facter::Memory.scale_number(swapfree.to_f,"MB")
    Facter::Memory::add_memfacts("SwapFree", meminfo, :aix)
end

if Facter.value(:kernel) == "OpenBSD"
    swap = Facter::Util::Resolution.exec('swapctl -l | sed 1d')
    swapfree, swaptotal = 0, 0
    swap.each do |dev|
        if dev =~ /^\S+\s+(\S+)\s+\S+\s+(\S+)\s+.*$/
            swaptotal += $1.to_i
            swapfree  += $2.to_i
        end
    end

    meminfo = Facter::Memory.scale_number(swaptotal.to_f,"kB")
    Facter::Memory::add_memfacts("SwapSize", meminfo, :openbsd)

    meminfo = Facter::Memory.scale_number(swapfree.to_f,"kB")
    Facter::Memory::add_memfacts("SwapFree", meminfo, :openbsd)

    memfree = Facter::Util::Resolution.exec("vmstat | tail -n 1 | awk '{ print $5 }'")
    meminfo = Facter::Memory.scale_number(memfree.to_f,"kB")
    Facter::Memory::add_memfacts("MemoryFree", meminfo, :openbsd)

    memtotal = Facter::Util::Resolution.exec("sysctl hw.physmem | cut -d'=' -f2")
    meminfo = Facter::Memory.scale_number(memfree.to_f,"")
    Facter::Memory::add_memfacts("MemoryTotal", meminfo, :openbsd)
end
