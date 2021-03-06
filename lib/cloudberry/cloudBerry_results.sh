#!/bin/bash
date=`date +'%Y-%m-%d'`
cases="./aaa"
cloudberry_result="nimbulaCloudBerryResults.xml"
release_version="14.1.16-20151106.040902-release"
component_name="HA-ComputeSvc"
subcommpont="serviceFailureResiliencyOneServiceFailure.storage"
#subcommpont="serviceFailureResiliency"
#subcommpont="GreenTest"
#bug="OCC-7558"
result="Automation Passed"
#result="Failed"

start_result()
{
cat <<EOF > $cloudberry_result
<?xml version="1.0" standalone="no"?>
<testresults>
EOF
}

end_result()
{
cat <<EOF >> $cloudberry_result
</testresults>
EOF
}
###############
# $0 case_name
###############
format_result()
{
case_name=$1
cat <<EOF >> $cloudberry_result
    <testresult>
        <testcase_name>$case_name</testcase_name>
        <env_name>qa_virtualized</env_name>
        <release_name>$release_version</release_name>
        <teststatus>$result</teststatus>
        <TestDuration></TestDuration>
        <product_name>Compute Service</product_name>
        <component_name>$component_name</component_name>
        <subcomponent_name>$subcommpont</subcomponent_name>
        <run_date>$date</run_date>
        <bug_number>$bug</bug_number>
        <comments>
        </comments>
    </testresult>
EOF
}

start_result
while read string;do
    echo $string
    format_result $string
done < $cases
end_result
