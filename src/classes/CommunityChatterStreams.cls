public without sharing class CommunityChatterStreams {
    @AuraEnabled
    public static List<ConnectApi.ChatterStream> getStreams() {
        return ConnectApi.ChatterFeeds.getStreams(Network.getNetworkId()).items;
    }
}