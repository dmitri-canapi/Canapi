/**
 * Based on mashup of:
 *   http://chrisaldridge.com/triggers/lightweight-apex-trigger-framework/
 *   http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers
 */ 
public interface ITriggerHandler {

    Boolean isDisabled();

    void bulkBefore();

    void bulkAfter();

    void beforeInsert(List<SObject> newItems);

    void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);

    void beforeDelete(Map<Id, SObject> oldItems);

    void afterInsert(Map<Id, SObject> newItems);

    void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);

    void afterDelete(Map<Id, SObject> oldItems);

    void afterUndelete(Map<Id, SObject> newItems);

    void andFinally();
}