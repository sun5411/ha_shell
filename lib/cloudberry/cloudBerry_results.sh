#!/bin/bash
date=`date +'%Y-%m-%d'`
cases="./aaa"
cloudberry_result="nimbulaCloudBerryResults.xml"
release_version="14.1.13-20141210.0133"
component_name="HA-ComputeSvc"

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
        <teststatus>Automation Passed</teststatus>
        <TestDuration>0.23</TestDuration>
        <product_name>Compute Service</product_name>
        <component_name>$component_name</component_name>
        <subcomponent_name>$case_name</subcomponent_name>
        <run_date>$date</run_date>
        <bug_number></bug_number>
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
