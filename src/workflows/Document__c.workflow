<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DocumentApproved</fullName>
        <description>DocumentApproved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Approval_Document_Approved</template>
    </alerts>
    <alerts>
        <fullName>DocumentRejected</fullName>
        <description>DocumentRejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Approval_Document_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Verify_Date</fullName>
        <field>Verify_Date__c</field>
        <formula>NOW()</formula>
        <name>Set Verify Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_as_verified</fullName>
        <field>Unverified__c</field>
        <literalValue>0</literalValue>
        <name>Set as verified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_unverified</fullName>
        <field>Unverified__c</field>
        <literalValue>1</literalValue>
        <name>Set unverified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
