#get all vms in a resource group, but you can remove -ResourceGroupName "xxx" to get all the vms in a subscription
$vms = Get-AzVM -ResourceGroupName "testcentosrg"

 #get the last 3 days data
 #end date
 $et=Get-Date

 #start date
 $st=$et.AddDays(-3)

 #define an array to store the infomation like vm name / resource group / cpu usage / network in / networkout
 $arr =@()

 foreach($vm in $vms)
 {
 #define a string to store related infomation like vm name etc. then add the string to an array
 $s = ""


 #percentage cpu usage
$cpu = Get-AzMetric -ResourceId $vm.Id -MetricName "Percentage CPU" -DetailedOutput -StartTime $st `
 -EndTime $et -TimeGrain 12:00:00  -WarningAction SilentlyContinue


 #network in
 $in = Get-AzMetric -ResourceId $vm.Id -MetricName "Network In" -DetailedOutput -StartTime $st `
 -EndTime $et  -TimeGrain 12:00:00 -WarningAction SilentlyContinue


 #network out 
$out = Get-AzMetric -ResourceId $vm.Id -MetricName "Network Out" -DetailedOutput -StartTime $st `
 -EndTime $et -TimeGrain 12:00:00  -WarningAction SilentlyContinue


 # 3 days == 72hours == 12*6hours

 $cpu_total=0.0
 $networkIn_total = 0.0
 $networkOut_total = 0.0

# foreach($c in $cpu.Data.Average)
# {
#  #this is a average value for 12 hours, so total = $c*12 (or should be $c*12*60*60)
#  $cpu_total += $c*12
# }
 foreach($c in $cpu.Data.Maximum)
 {
  #this is a average value for 12 hours, so total = $c*12 (or should be $c*12*60*60)
  $cpu_total += $c*12
  #($c|measure -maximum).maximum
 }
 foreach($i in $in.Data.total)
 {
  $networkIn_total += $i 
 }

 foreach($t in $out.Data.total)
 {
  $networkOut_total += $t
 }

 # add all the related info to the string
 $s = "VM Name: " + $vm.name + "; Resource Group: " + $vm.ResourceGroupName + "; CPU: " +$cpu_total +"; Network In: " + $networkIn_total + "; Network Out: " + $networkOut_total

 # add the above string to an array
 $arr += $s
 }

 #check the values in the array
 $arr
