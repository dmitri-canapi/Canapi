(window._walkmeABWebpackJP_latest=window._walkmeABWebpackJP_latest||[]).push([[5],{303:function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(t,"__esModule",{value:!0});var a=r(n(239)),o=r(n(179)),u="middleEndian",i="date",c="number",l="comma";t.default=function(e,t){switch(e&&e.type){case i:return function(e,t){var n=new Date(e.value);if(!(0,o.default)(n))return e;var r=function(e){return e?e.replace(/(D+)|(Y+)/g,function(e){return e.toLowerCase()}):e}(t);if(!r)switch(e.settings&&e.settings.format){case u:r="MM/dd/yyyy";break;default:r="dd/MM/yyyy"}return(0,a.default)(n,r)}(e,t);case c:return function(e){return e.settings&&e.settings.decimalSeparator===l?String(e.value).replace(/\./g,","):e.value}(e);default:return e&&e.value}}},304:function(e,t,n){"use strict";(function(e,r,a){Object.defineProperty(t,"__esModule",{value:!0});var o,u=n(93),i=(o=u)&&o.__esModule?o:{default:o};t.default={getItem:function(e){return i.default.deps.clientStorageManager.getData("wm-ab-"+e)},setItem:function(e,t){return i.default.deps.clientStorageManager.saveData("wm-ab-"+e,t,arguments.length>2&&void 0!==arguments[2]?arguments[2]:600,arguments[3])},removeItem:function(e){var t;return(t=i.default.deps.clientStorageManager).removeData.apply(t,["wm-ab-"+e].concat(function(e){if(Array.isArray(e)){for(var t=0,n=Array(e.length);e.length>t;t++)n[t]=e[t];return n}return r(e)}(arguments.length>1&&void 0!==arguments[1]?arguments[1]:{})))},clear:function(){},sync:function(){var t,n=(t=a.mark(function t(){return a.wrap(function(t){for(;;)switch(t.prev=t.next){case 0:return t.abrupt("return",new e(function(e){i.default.deps.clientStorageManager.refreshGetData(null,function(){e()})}));case 1:case"end":return t.stop()}},t,this)}),function(){var n=t.apply(this,arguments);return new e(function(t,r){return function a(o,u){try{var i=n[o](u),c=i.value}catch(e){return void r(e)}if(!i.done)return e.resolve(c).then(function(e){a("next",e)},function(e){a("throw",e)});t(c)}("next")})});return function(){return n.apply(this,arguments)}}()}}).call(this,n(18).Promise,n(38).from,n(35))},38:function(e){"use strict";var t=Object.prototype.toString,n=function(e){return"function"==typeof e||"[object Function]"===t.call(e)},r=Math.pow(2,53)-1,a=function(e){var t=function(e){var t=Number(e);return isNaN(t)?0:0!==t&&isFinite(t)?(t>0?1:-1)*Math.floor(Math.abs(t)):t}(e);return Math.min(Math.max(t,0),r)};e.exports={get from(){return window&&window.Array&&window.Array.from&&"function"==typeof window.Array.from.toString&&String(window.Array.from.toString()).indexOf("[native code]")>-1?window.Array.from:function(e){var t=Object(e);if(null==e)throw new TypeError("Array.from requires an array-like object - not null or undefined");var r,o=arguments.length>1?arguments[1]:void 0;if(void 0!==o){if(!n(o))throw new TypeError("Array.from: when provided, the second argument must be a function");arguments.length>2&&(r=arguments[2])}for(var u,i=a(t.length),c=n(this)?Object(new this(i)):new Array(i),l=0;i>l;)u=t[l],c[l]=o?void 0===r?o(u,l):o.call(r,u,l):u,l+=1;return c.length=i,c}}}},386:function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(t,"__esModule",{value:!0}),t.generateStartedAppKey=t.safeReject=t.safeResolve=t.noop=t.resolveVariablesInText=t.isTextHasVariable=t.parseVarName=t.extractVariableName=void 0;var a=function(){return function(e,t){if(Array.isArray(e))return e;if(Symbol.iterator in Object(e))return function(e,t){var n=[],r=!0,a=!1,o=void 0;try{for(var u,i=e[Symbol.iterator]();!(r=(u=i.next()).done)&&(n.push(u.value),!t||n.length!==t);r=!0);}catch(e){a=!0,o=e}finally{try{!r&&i.return&&i.return()}finally{if(a)throw o}}return n}(e,t);throw new TypeError("Invalid attempt to destructure non-iterable instance")}}();t.resolveVariable=function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"",t=void 0;try{h(e)&&(t=y(e))}catch(e){l.default.error(e)}return t||e};var o=r(n(155)),u=r(n(33)),i=r(n(304)),c=r(n(303)),l=r(n(124)),s=/\${([^{]+)}/g,f=function(e){return e.replace(/\\/g,"")},d=t.extractVariableName=function(){return f(arguments.length>0&&void 0!==arguments[0]?arguments[0]:"").replace(/\${(.*)}/,"$1")},p=function(e){return function(e){return f(e).match(s)||[]}(e).map(function(e){return d(e)})},v=t.parseVarName=function(){return f(arguments.length>0&&void 0!==arguments[0]?arguments[0]:"").split("@")},h=t.isTextHasVariable=function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"";return"string"==typeof e&&Boolean(f(e).match(s))},y=t.resolveVariablesInText=function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"",t=p(e);if(!t.length)return e;var n=t.map(function(e){var t=v(e),n=a(t,2),r=n[1];return(0,c.default)(i.default.getItem(n[0]),r)}),r=f(e);return t.forEach(function(e,t){void 0!==n[t]&&(r=r.replace("${"+e+"}",n[t]))}),(0,o.default)(r)},m=t.noop=function(){};t.safeResolve=function(e,t){(0,u.default)(e,"resolve",m)(t)},t.safeReject=function(e,t){(0,u.default)(e,"reject",m)(t)},t.generateStartedAppKey=function(e,t){return e+"-"+t+"-started"}},387:function(e,t,n){"use strict";(function(e){function r(e){return e&&e.__esModule?e:{default:e}}function a(t){if(Array.isArray(t)){for(var n=0,r=Array(t.length);t.length>n;n++)r[n]=t[n];return r}return e(t)}Object.defineProperty(t,"__esModule",{value:!0});var o=r(n(93)),u=r(n(124)),i=n(68),c=r(n(437)),l=function(e){try{var t=o.default.deps.wmjQuery,n=t();if(!e)return n;t.merge(n,t(e));try{var r=window.frames;if(!r||!r.length)return n;[].concat(a(r)).forEach(function(r){var a=t(e,r.document);t.merge(n,a)})}catch(e){}return n}catch(e){return u.default.error(e),o.default.deps.wmjQuery()}};t.default={init:function(){!function(){try{var e=c.default.toString(),t=document.createElement("style"),n=document.createTextNode(e);t.className="walkme-to-remove",t.appendChild(n),(document.head||document.getElementsByTagName("head")[0]).appendChild(t);try{var r=window.frames;r&&r.length&&[].concat(a(r)).forEach(function(t){var n=document.createElement("style"),r=document.createTextNode(e);n.className="walkme-to-remove",n.appendChild(r),(t.document.head||t.document.getElementsByTagName("head")[0]).appendChild(n)})}catch(e){}}catch(e){u.default.error(e)}}()},show:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{};switch(e.type){case i.WM_DEPLOYABLE_IDS.launcher:!function(e){if(e){var t=o.default.deps.wmjQuery,n=l(".walkme-launcher-id-"+e);if(n.length&&!n.find(".wm-ab-launcher-spinner").length){var r=t("<div>");r.addClass("wm-ab-launcher-spinner"),n.append(r)}}}(e.id)}},remove:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{};switch(e.type){case i.WM_DEPLOYABLE_IDS.launcher:!function(e){if(e){var t=l(".walkme-launcher-id-"+e);t.length&&t.find(".wm-ab-launcher-spinner").remove()}}(e.id)}},removeAll:function(){l(".wm-ab-launcher-spinner").remove()}}}).call(this,n(38).from)},388:function(e,t,n){"use strict";(function(e,r,a,o){function u(e){return e&&e.__esModule?e:{default:e}}function i(e){return function(){var t=e.apply(this,arguments);return new r(function(e,n){return function a(o,u){try{var i=t[o](u),c=i.value}catch(e){return void n(e)}if(!i.done)return r.resolve(c).then(function(e){a("next",e)},function(e){a("throw",e)});e(c)}("next")})}}function c(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}Object.defineProperty(t,"__esModule",{value:!0}),t.ACTIONS_REQUIRE_DATA_SAVE=void 0;var l,s,f,d=e||function(e){for(var t=1;arguments.length>t;t++){var n=arguments[t];for(var r in n)Object.prototype.hasOwnProperty.call(n,r)&&(e[r]=n[r])}return e},p=function(){return function(e,t){if(Array.isArray(e))return e;if(Symbol.iterator in Object(e))return function(e,t){var n=[],r=!0,a=!1,o=void 0;try{for(var u,i=e[Symbol.iterator]();!(r=(u=i.next()).done)&&(n.push(u.value),!t||n.length!==t);r=!0);}catch(e){a=!0,o=e}finally{try{!r&&i.return&&i.return()}finally{if(a)throw o}}return n}(e,t);throw new TypeError("Invalid attempt to destructure non-iterable instance")}}(),v=u(n(93)),h=u(n(387)),y=u(n(124)),m=u(n(304)),g=u(n(389)),w=u(n(439)),b=n(386),_=n(21),A=n(68),T=function(e){if(e&&e.__esModule)return e;var t={};if(null!=e)for(var n in e)Object.prototype.hasOwnProperty.call(e,n)&&(t[n]=e[n]);return t.default=e,t}(n(24)),S=t.ACTIONS_REQUIRE_DATA_SAVE=[T.START_WALKTHRU,T.START_SMARTWALKTHRU,T.SMARTWALKTHRU,T.WALKTHRU,T.SURVEY,T.SHOUTOUT,T.SHUTTLE,T.RESOURCE],E=void 0,O=void 0,I=void 0,x=!1,M=!1,k=function(e,t){var n=arguments.length>2&&void 0!==arguments[2]?arguments[2]:{};return!!(t.webSystemGuid&&t.destinationUrl&&t.permalink)||!!n.syncSwtDataToOtherAccounts&&n.syncSwtDataToOtherAccounts.some(function(t){return t.conversationId.includes(e.toString())})},R=function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{};try{return e.type===t.type&&e.id===t.id}catch(e){return!1}},L=function(t){var n=t.answers,r=void 0;try{r=v.default.deps.eventsTrigger.sync(_.EXT_ACTIONBOT_ACTION,n)}catch(e){y.default.error(e)}var o=window.location,u=o.host;return e(n,{returnUrl:n.returnUrl||{type:"string",value:u+o.pathname},returnBaseUrl:n.returnBaseUrl||{type:"string",value:u}},r||{}),a(n).forEach(function(e){var t=p(e,2);return m.default.setItem(t[0],t[1])}),m.default.sync()},P=(c(l={},T.START_SMARTWALKTHRU,v.default.startFlowById),c(l,T.START_WALKTHRU,v.default.startFlowById),c(l,T.SMARTWALKTHRU,v.default.startFlowById),c(l,T.WALKTHRU,v.default.startWalkthruById),c(l,T.SURVEY,v.default.playSurveyById),c(l,T.SHOUTOUT,v.default.playShoutOutById),c(l,T.RESOURCE,v.default.playResourceById),c(l,T.SHUTTLE,v.default.playShuttleById),c(l,T.MENU,v.default.openMenu),l),B=(c(s={},T.START_SMARTWALKTHRU,{eventKey:"FlowCompleted",dataKey:"businessSolutionId"}),c(s,T.START_WALKTHRU,{eventKey:"FlowCompleted",dataKey:"businessSolutionId"}),c(s,T.SMARTWALKTHRU,{eventKey:"FlowCompleted",dataKey:"businessSolutionId"}),c(s,T.SHOUTOUT,{eventKey:"ShoutOutClosed",dataKey:"businessSolutionId"}),s),j=function(e){return new r((t=i(o.mark(function t(n){var r,a,u,i,c,l,s,f;return o.wrap(function(t){for(;;)switch(t.prev=t.next){case 0:if(u=(r=e.settings).id,S.indexOf(a=r.app)<=-1){t.next=4;break}return t.next=4,L(e);case 4:(i=P[a])&&(a&&m.default.setItem((0,b.generateStartedAppKey)(a,u),!0),i(u),B[a]?(s=(c=B[a]).dataKey,v.default.deps.eventsListener.bind(l=c.eventKey,function e(t,r){(r&&r[s]===u||r.shoutOut&&r.shoutOut.Id===u)&&(v.default.deps.eventsListener.unbind(l,e),n())})):n()),a===T.LIVE_CHAT&&((f=v.default.getLiveChat())?f.chat.openChat():y.default.warn("[ActionBot] LiveChat doesn't present on ctx"),n());case 7:case"end":return t.stop()}},t,void 0)})),function(){return t.apply(this,arguments)}));var t},U=function(e){return(v.default.getSettingsFile()||{}).CdnServerName+"/chatbot/action-bot-landing-page/index.html"+"?"+a(d({},e.options,{envId:v.default.getEnvId(),userGuid:v.default.getUserGuid()})).map(function(e){var t=p(e,2);return t[0]+"="+encodeURIComponent(t[1])}).join("&")},D=function(e){h.default.remove(E),O.hide(),x=!1,v.default.deps.commonEvents.raiseEvent(T.EXT_BOT_DUI_CLOSE),e&&v.default.deps.commonEvents.raiseEvent(T.BOT_CLOSE)},C=(f=i(o.mark(function e(t,a){var u,c,l,s,f,p,_;return o.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:if(e.prev=0,u=a.botId,l=void 0===(c=a.additionalSettings)?{}:c,f=void 0===(s=a.globalConfig)?{}:s,t||y.default.error(new Error("Initiator is mandatory when opening DialogUI."),!0),p=t.type!==A.WM_DEPLOYABLE_IDS.event&&R(E,t)&&x,E=t,O){e.next=13;break}return e.next=8,new r(function(e){r.all([n.e(2),n.e(3)]).then(function(){e(n(774))}.bind(null,n)).catch(n.oe)});case 8:if(e.t0=e.sent,e.t0){e.next=11;break}e.t0={};case 11:O=new(0,e.t0.default);case 13:if(_=v.default.getFeaturesManager().isFeatureEnabled||v.default.isActionBotFeaturesEnabled,M){e.next=32;break}return e.next=17,O.init({userGuid:v.default.getUserGuid(),walkmeEndUserId:v.default.getEndUserGuid(),walkmeOpenUrl:v.default.openUrlWithWalkMe,isWorkstation:v.default.isWorkstation(),envId:v.default.getEnvId(),apiBaseUrl:v.default.getApiBaseUrl(),publicPath:v.default.getPublicPath(),uuid:m.default.getItem("euid"),siteConfig:v.default.getSiteConfig(),clientSideSFOauth:_("clientSideSFOauth"),evaluateTagsById:v.default.evaluateTagsById,globalConfig:f});case 17:m.default.setItem("euid",e.sent.uuid,63072e3),M=!0,O.on(T.BOT_SHOW,function(e){try{h.default.remove(E),x=!0,v.default.deps.commonEvents.raiseEvent(T.EXT_BOT_DUI_SHOW,a),l.playMode&&v.default.deps.commonEvents.raiseEvent(T.BOT_SHOW)}catch(e){y.default.error(e)}(0,b.safeResolve)(e)}),O.on(T.BOT_HIDE,function(e){(0,b.safeResolve)(e),x=!1}),O.on(T.BOT_CLOSE,function(e){try{D(l.playMode)}catch(e){y.default.error(e)}(0,b.safeResolve)(e)}),O.on(T.BOT_ANALYTICS_EVENT,function(e){var t=e.type,n=e.data,r=e.options;try{var a=d({},r.skipPInit||n.pInit?null:{pInit:{id:E.id||null,type:E.type||A.WM_DEPLOYABLE_IDS.launcher,appType:E.type||A.WM_DEPLOYABLE_IDS.launcher}},n);(0,w.default)(t,a)}catch(e){y.default.error(e)}}),O.on(T.WALK_ME_ACTION,function(){var e=i(o.mark(function e(t){var n,r;return o.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:if(n=U(t),v.default.deps.commonEvents.raiseEvent(l.playMode?T.WALK_ME_ACTION:T.EXT_BOT_DUI_ACTION,d({},t,{landingPageUrl:n})),!((r=v.default.getUserJsonSettings())&&t.options&&t.settings&&k(t.options.conversationId,t.settings,r.actionbot))){e.next=7;break}window.open(n),e.next=17;break;case 7:if(g.default.skipWalkMeAction()){e.next=17;break}return e.prev=8,e.next=11,j(t);case 11:(0,b.safeResolve)(t),e.next=17;break;case 14:e.prev=14,e.t0=e.catch(8),(0,b.safeReject)(t,e.t0);case 17:case"end":return e.stop()}},e,void 0,[[8,14]])}));return function(){return e.apply(this,arguments)}}()),O.on(T.GET_APP_STARTED_FLAG,function(){var e=i(o.mark(function e(t){var n;return o.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:try{n=m.default.getItem((0,b.generateStartedAppKey)(t.app,t.id)),(0,b.safeResolve)(t,n)}catch(e){(0,b.safeReject)(t,e)}case 1:case"end":return e.stop()}},e,void 0)}));return function(){return e.apply(this,arguments)}}()),O.on(T.CLEAN_APP_STARTED_FLAG,function(){var e=i(o.mark(function e(t){return o.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return e.prev=0,m.default.removeItem((0,b.generateStartedAppKey)(t.app,t.id)),e.next=5,m.default.sync();case 5:(0,b.safeResolve)(t),e.next=11;break;case 8:e.prev=8,e.t0=e.catch(0),(0,b.safeReject)(t,e.t0);case 11:case"end":return e.stop()}},e,void 0,[[0,8]])}));return function(){return e.apply(this,arguments)}}()),O.on(T.INITIAL_DATA_LOAD_FAIL,function(e){try{h.default.remove(E),I=null}catch(e){y.default.error(e)}(0,b.safeResolve)(e)}),O.on(T.SEND_ERROR_TO_LOGZ,function(e){y.default.error(e.error,e.clientRelated),(0,b.safeResolve)(e)}),O.on(T.WALKME_SEARCH,function(){var e=i(o.mark(function e(t){return o.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return e.prev=0,e.next=3,v.default.searchDeployables(t.searchTerm);case 3:(0,b.safeResolve)(t,e.sent),e.next=11;break;case 7:e.prev=7,e.t0=e.catch(0),y.default.error(e.t0),(0,b.safeReject)(t,e.t0);case 11:case"end":return e.stop()}},e,void 0,[[0,7]])}));return function(){return e.apply(this,arguments)}}()),O.on(T.RESOLVE_BBCODES,function(){var e=i(o.mark(function e(t){return o.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:try{(0,b.safeResolve)(t,v.default.resolveBBCodes(t.text))}catch(e){y.default.error(e),(0,b.safeReject)(t,e)}case 1:case"end":return e.stop()}},e,void 0)}));return function(){return e.apply(this,arguments)}}());case 32:if(!u||p){e.next=39;break}return O.hide(),e.next=36,O.open(a,I===u);case 36:I=u,e.next=42;break;case 39:O.hide(),h.default.remove(E),x=!1;case 42:e.next=49;break;case 44:e.prev=44,e.t1=e.catch(0),h.default.remove(E),[T.INITIAL_DATA_LOAD_FAIL].indexOf(e.t1)>-1&&y.default.error(e.t1);case 49:case"end":return e.stop()}},e,void 0,[[0,44]])})),function(){return f.apply(this,arguments)});t.default={open:C,close:D,destroy:function(){O&&(O.close(),O=null)}}}).call(this,n(4).assign,n(18).Promise,n(4).entries,n(35))},389:function(e,t){"use strict";Object.defineProperty(t,"__esModule",{value:!0}),t.default={init:function(e){this.config=e},skipWalkMeAction:function(){return this.config&&this.config.skipWalkMeAction}}},437:function(e,t,n){(e.exports=n(438)(!1)).push([e.i,".wm-ab-launcher-spinner {\n  height: 100%;\n  left: 0;\n  position: absolute;\n  top: 0;\n  width: 100%;\n}\n\n.wm-ab-launcher-spinner::before {\n  animation: wm-ab-spin 1.5s linear infinite;\n  border: 2px solid #f3f3f3;\n  border-radius: 50%;\n  border-top: 2px solid transparent;\n  content: '';\n  height: 18px;\n  left: calc(50% - 9px);\n  position: absolute;\n  top: calc(50% - 9px);\n  width: 18px;\n}\n\n@keyframes wm-ab-spin {\n  0% {\n    transform: rotate(0deg);\n  }\n\n  100% {\n    transform: rotate(360deg);\n  }\n}\n",""])},439:function(e,t,n){"use strict";Object.defineProperty(t,"__esModule",{value:!0});var r,a=n(93),o=(r=a)&&r.__esModule?r:{default:r};t.default=function(e,t){return o.default.deps.eventSender.postEvent(e,t)}},775:function(e,t,n){"use strict";(function(e,r){function a(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(t,"__esModule",{value:!0});var o=a(n(779)),u=a(n(93)),i=a(n(387)),c=a(n(389));t.default={init:function(){var t,n=(t=r.mark(function e(t){var n=t.wmDependencies,a=t.config;return r.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:u.default.init(n),c.default.init(a),i.default.init(),o.default.init();case 4:case"end":return e.stop()}},e,this)}),function(){var n=t.apply(this,arguments);return new e(function(t,r){return function a(o,u){try{var i=n[o](u),c=i.value}catch(e){return void r(e)}if(!i.done)return e.resolve(c).then(function(e){a("next",e)},function(e){a("throw",e)});t(c)}("next")})});return function(){return n.apply(this,arguments)}}()}}).call(this,n(18).Promise,n(35))},778:function(e,t,n){"use strict";(function(e){Object.defineProperty(t,"__esModule",{value:!0}),t.restoreWindowOpen=function(){i.open&&"function"==typeof i.open&&e(o.default.deps.win,{open:i.open})},t.default=function(){var t=o.default.deps.win,n=t.open;e(i,{open:n}),t.open=function(e){for(var t=arguments.length,r=Array(t>1?t-1:0),a=1;t>a;a++)r[a-1]=arguments[a];return n.apply(void 0,[(0,u.resolveVariable)(e)].concat(r))}};var r,a=n(93),o=(r=a)&&r.__esModule?r:{default:r},u=n(386),i={}}).call(this,n(4).assign)},779:function(e,t,n){"use strict";(function(e,r,a){function o(e){return e&&e.__esModule?e:{default:e}}function u(e,t){d.default.deps.eventsListener.bind(e,t),_.push({key:e,func:t})}function i(){var t,n,o=this,i=d.default.deps.consts.EVENTS.Launchers.LauncherClicked,c=d.default.getLaunchers(),l=c&&c.reduce(function(t,n){var r,a,o;return e(t,(o=n,(a=n.Id)in(r={})?Object.defineProperty(r,a,{value:o,enumerable:!0,configurable:!0,writable:!0}):r[a]=o,r)),t},{});return u(i,(t=a.mark(function e(t,n){var r,u,i,c,s,y,w,_,A,T,S,E,O,I=n.launcherId;return a.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:if(e.prev=0,r=l[I],!b&&r&&d.default.isValidLauncher(r)){e.next=4;break}return e.abrupt("return");case 4:if(b=!0,I){e.next=7;break}throw new Error("[Integration: launcher click listener] Launcher ID isn't present in data");case 7:if(i=(u={}).botId,c=u.conversationId,w=(s=r.Settings.action).arguments,(y=s.actionType)!==g.ACTION_TYPE_NONE){e.next=27;break}return e.next=12,(0,p.default)();case 12:if(e.t0=e.sent,e.t0){e.next=15;break}e.t0={};case 15:if(A=void 0===(_=e.t0.launchers)?{}:_,-1!==Object.keys(A).map(Number).indexOf(I)){e.next=22;break}return b=!1,e.abrupt("return");case 22:i=(T=A[I]||{}).bot,c=T.conversation,e.next=28;break;case 27:y===g.ACTION_TYPE_ACTION_BOT&&(E=(S=w||{}).actionBotConversationId,i=Number(S.actionBotId),c=Number(E));case 28:return h.default.show(O={id:I,type:m.WM_DEPLOYABLE_IDS.launcher}),e.next=32,v.default.open(O,{botId:i,conversationId:c});case 32:b=!1,e.next=39;break;case 35:e.prev=35,e.t1=e.catch(0),b=!1,f.default.error(e.t1);case 39:case"end":return e.stop()}},e,o,[[0,35]])}),n=function(){var e=t.apply(this,arguments);return new r(function(t,n){return function a(o,u){try{var i=e[o](u),c=i.value}catch(e){return void n(e)}if(!i.done)return r.resolve(c).then(function(e){a("next",e)},function(e){a("throw",e)});t(c)}("next")})},function(){return n.apply(this,arguments)}))}function c(){return u(d.default.deps.consts.EVENTS.WalkmeReady,function(){try{!function(){var e=window.location.search,t=/\?walkme=(\d+)-(\d+)(-(\d+))?/.exec(e);if(t){var n=s(t,5),r=n[1],a=n[2],o=n[4];if(Number(r)===m.ACTIONBOT_DEPLOYABLE_TYPE&&a){var u=l({botId:Number(a)},o&&{conversationId:Number(o)}),i={id:[r,a,o].filter(Boolean).join("-"),type:m.WM_DEPLOYABLE_IDS.permalink};v.default.open(i,u)}}}()}catch(e){f.default.error(e)}})}Object.defineProperty(t,"__esModule",{value:!0}),t.addWalkMeApi=void 0;var l=e||function(e){for(var t=1;arguments.length>t;t++){var n=arguments[t];for(var r in n)Object.prototype.hasOwnProperty.call(n,r)&&(e[r]=n[r])}return e},s=function(){return function(e,t){if(Array.isArray(e))return e;if(Symbol.iterator in Object(e))return function(e,t){var n=[],r=!0,a=!1,o=void 0;try{for(var u,i=e[Symbol.iterator]();!(r=(u=i.next()).done)&&(n.push(u.value),!t||n.length!==t);r=!0);}catch(e){a=!0,o=e}finally{try{!r&&i.return&&i.return()}finally{if(a)throw o}}return n}(e,t);throw new TypeError("Invalid attempt to destructure non-iterable instance")}}(),f=o(n(124)),d=o(n(93)),p=o(n(780)),v=o(n(388)),h=o(n(387)),y=o(n(782)),m=n(68),g=n(21),w=n(778),b=!1,_=[],A=t.addWalkMeApi=function(){e(d.default.deps.classWalkMeAPI,{actionbot:{open:function(e){return v.default.open({type:m.WM_DEPLOYABLE_IDS.api},{botId:e.botId,conversationId:e.conversationId,globalConfig:e.globalConfig})},close:function(){return v.default.close()}}})};t.default={init:function(){y.default.init(),A(),c(),i(),u(d.default.deps.consts.EVENTS.BeforeWalkmeRemoved,function(){try{v.default.destroy();try{d.default.deps.wmjQuery('script[src*="chatbot"], script[src*="local"]').remove()}catch(e){}if(h.default.removeAll(),_&&_.length)for(;_.length;){var e=_.pop();d.default.deps.eventsListener.unbind(e.key,e.func)}["_walkmeABWebpackJP_latest","__wm-ab-core-js_shared__latest"].forEach(function(e){window.hasOwnProperty(e)&&delete window[e]}),window.open&&"function"==typeof window.open&&window.open.toString().indexOf("resolveVariable")>-1&&(0,w.restoreWindowOpen)()}catch(e){f.default.error(e)}}),u("wmActionBotRun",function(e){v.default.open({type:m.WM_DEPLOYABLE_IDS.event},e)})}}}).call(this,n(4).assign,n(18).Promise,n(35))},780:function(e,t,n){"use strict";(function(e,r){function a(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(t,"__esModule",{value:!0});var o,u,i=a(n(781)),c=a(n(93)),l=void 0,s=(o=r.mark(function e(){var t,n,a;return r.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:if(l){e.next=9;break}return t=c.default.getUserGuid(),n=c.default.getEnvId(),a=c.default.getSettingsFile(),e.next=6,(0,i.default)({url:"/chatbot/settings",baseURL:a.PlayerApiServer,headers:{"x-wmab-wmenv":n},params:{userGuid:t}});case 6:l=e.sent.data;case 9:return e.abrupt("return",l);case 10:case"end":return e.stop()}},e,void 0)}),u=function(){var t=o.apply(this,arguments);return new e(function(n,r){return function a(o,u){try{var i=t[o](u),c=i.value}catch(e){return void r(e)}if(!i.done)return e.resolve(c).then(function(e){a("next",e)},function(e){a("throw",e)});n(c)}("next")})},function(){return u.apply(this,arguments)});t.default=s}).call(this,n(18).Promise,n(35))},781:function(e,t,n){"use strict";(function(e){Object.defineProperty(t,"__esModule",{value:!0});var r,a=n(93),o=(r=a)&&r.__esModule?r:{default:r};t.default=function(t){var n=t.type,r=void 0===n?"GET":n,a=t.baseURL,u=t.url,i=t.headers,c=t.params;return new e(function(e,t){try{o.default.deps.wmAjax.execute({type:r,url:a+u,data:c,dataType:"json",headers:i,success:function(t){e({data:t})},error:function(){for(var e=arguments.length,n=Array(e),r=0;e>r;r++)n[r]=arguments[r];t(n)}})}catch(e){t(e)}})}}).call(this,n(18).Promise)},782:function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(t,"__esModule",{value:!0});var a=r(n(783)),o=r(n(784)),u=r(n(785)),i=r(n(786)),c=r(n(778));t.default={init:function(){(0,a.default)(),(0,o.default)(),(0,u.default)(),(0,i.default)(),(0,c.default)()}}},783:function(e,t,n){"use strict";(function(e){function r(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(t,"__esModule",{value:!0}),t.default=function(){var t=a.default.deps.actionStagesFactory,n=t.createActionStage;t.createActionStage=function(t){for(var r=arguments.length,a=Array(r>1?r-1:0),i=1;r>i;i++)a[i-1]=arguments[i];try{if(t&&"Redirect"===t.ActionType&&t.Settings&&t.Settings.actionArgs&&t.Settings.actionArgs.url){var c=t.Settings.actionArgs.url;(0,o.isTextHasVariable)(c)&&e(t.Settings.actionArgs,{url:(0,o.resolveVariablesInText)(c)})}}catch(e){u.default.error(e)}return n.apply(void 0,[t].concat(a))}};var a=r(n(93)),o=n(386),u=r(n(124))}).call(this,n(4).assign)},784:function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(t,"__esModule",{value:!0});var a=function(){return function(e,t){if(Array.isArray(e))return e;if(Symbol.iterator in Object(e))return function(e,t){var n=[],r=!0,a=!1,o=void 0;try{for(var u,i=e[Symbol.iterator]();!(r=(u=i.next()).done)&&(n.push(u.value),!t||n.length!==t);r=!0);}catch(e){a=!0,o=e}finally{try{!r&&i.return&&i.return()}finally{if(a)throw o}}return n}(e,t);throw new TypeError("Invalid attempt to destructure non-iterable instance")}}();t.default=function(){var e=o.default.deps.clientStorageManager,t=e.getData;e.getData=function(e){for(var n=arguments.length,r=Array(n>1?n-1:0),o=1;n>o;o++)r[o-1]=arguments[o];try{if((0,u.isTextHasVariable)(e)){var s=(0,u.extractVariableName)(e),f=(0,u.parseVarName)(s),d=a(f,2),p=d[1],v=i.default.getItem(d[0]);if(v&&v.value)return(0,c.default)(v,p)}}catch(e){l.default.error(e)}return t.apply(void 0,[e].concat(r))}};var o=r(n(93)),u=n(386),i=r(n(304)),c=r(n(303)),l=r(n(124))},785:function(e,t,n){"use strict";Object.defineProperty(t,"__esModule",{value:!0}),t.default=function(){var e=o.default.deps.inputGenerator,t=e.text,n=e.selectByText;e.text=function(e,n){for(var r=arguments.length,a=Array(r>2?r-2:0),o=2;r>o;o++)a[o-2]=arguments[o];return t.apply(void 0,[e,(0,u.resolveVariable)(n)].concat(a))},e.selectByText=function(e,t){for(var r=arguments.length,a=Array(r>2?r-2:0),o=2;r>o;o++)a[o-2]=arguments[o];return n.apply(void 0,[e,(0,u.resolveVariable)(t)].concat(a))}};var r,a=n(93),o=(r=a)&&r.__esModule?r:{default:r},u=n(386)},786:function(e,t,n){"use strict";Object.defineProperty(t,"__esModule",{value:!0}),t.default=function(){var e=o.default.deps.jQuerySelectorRunner,t=e.run;e.run=function(e){for(var n=arguments.length,r=Array(n>1?n-1:0),a=1;n>a;a++)r[a-1]=arguments[a];return t.apply(void 0,[(0,u.resolveVariable)(e)].concat(r))}};var r,a=n(93),o=(r=a)&&r.__esModule?r:{default:r},u=n(386)}}]);