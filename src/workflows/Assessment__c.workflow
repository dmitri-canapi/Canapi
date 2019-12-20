<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Assessment_Approval_Process</fullName>
        <description>Assessment Approval Process</description>
        <protected>false</protected>
        <recipients>
            <recipient>nu@canapi.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>peter.underwood1@liveoakbank.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>timurd@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Approval_Process</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assessment_Reject_Approval</fullName>
        <field>Review_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Assessment Reject Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Complete_Assessment_Approval</fullName>
        <field>Review_Status__c</field>
        <literalValue>Approved Complete</literalValue>
        <name>Complete Assessment Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submitted</fullName>
        <field>Submitted__c</field>
        <literalValue>1</literalValue>
        <name>Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submitted_Removed</fullName>
        <field>Submitted__c</field>
        <literalValue>0</literalValue>
        <name>Submitted - Removed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
