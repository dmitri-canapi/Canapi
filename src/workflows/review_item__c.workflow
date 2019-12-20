<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>In_File_Status</fullName>
        <field>Review_Item_Status__c</field>
        <literalValue>In File</literalValue>
        <name>In File Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Infile Status</fullName>
        <actions>
            <name>In_File_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>review_item__c.Finished__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When Finished__c checkbox set to TRUE, changes Status to In File.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
