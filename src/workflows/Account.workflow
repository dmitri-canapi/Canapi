<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Use_Google_to_Geocode_true</fullName>
        <description>Sets the Account checkbox &quot;Use Google to Geocode&quot; = true which will kick off the callout to the Google Maps API.</description>
        <field>Use_Google_to_Geocode__c</field>
        <literalValue>1</literalValue>
        <name>Set &quot;Use Google to Geocode&quot; = true</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account - Use Google to Geocode</fullName>
        <actions>
            <name>Set_Use_Google_to_Geocode_true</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule kicks off geocoding using the Google Maps API. Should only fire for accounts that Salesforce won&apos;t geocode itself due to missing Shipping Street and Shipping Postal Code values.</description>
        <formula>(ISNEW() || ISCHANGED(ShippingStreet) || ISCHANGED(ShippingCity) || ISCHANGED(ShippingState) || ISCHANGED(ShippingCountry) || ISCHANGED(ShippingPostalCode)) &amp;&amp; ISBLANK(ShippingStreet) &amp;&amp; ISBLANK(ShippingPostalCode)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
