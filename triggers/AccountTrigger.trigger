trigger AccountTrigger on Account (before insert) {

    AccountTriggerHandler.SetDefaultValues(Trigger.new);
    AccountTriggerHandler.PreventDuplicatesByName();
}