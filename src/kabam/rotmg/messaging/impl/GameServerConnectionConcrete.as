﻿//kabam.rotmg.messaging.impl.GameServerConnectionConcrete

package kabam.rotmg.messaging.impl
	{
	import com.company.assembleegameclient.game.AGameSprite;
	import com.company.assembleegameclient.game.events.GuildResultEvent;
	import com.company.assembleegameclient.game.events.KeyInfoResponseSignal;
	import com.company.assembleegameclient.game.events.NameResultEvent;
	import com.company.assembleegameclient.game.events.ReconnectEvent;
	import com.company.assembleegameclient.map.AbstractMap;
	import com.company.assembleegameclient.map.GroundLibrary;
	import com.company.assembleegameclient.map.Map;
	import com.company.assembleegameclient.map.mapoverlay.CharacterStatusText;
	import com.company.assembleegameclient.objects.Container;
	import com.company.assembleegameclient.objects.FlashDescription;
	import com.company.assembleegameclient.objects.GameObject;
	import com.company.assembleegameclient.objects.Merchant;
	import com.company.assembleegameclient.objects.NameChanger;
	import com.company.assembleegameclient.objects.ObjectLibrary;
	import com.company.assembleegameclient.objects.ObjectProperties;
	import com.company.assembleegameclient.objects.Pet;
	import com.company.assembleegameclient.objects.Player;
	import com.company.assembleegameclient.objects.Portal;
	import com.company.assembleegameclient.objects.Projectile;
	import com.company.assembleegameclient.objects.ProjectileProperties;
	import com.company.assembleegameclient.objects.SellableObject;
	import com.company.assembleegameclient.objects.particles.AOEEffect;
	import com.company.assembleegameclient.objects.particles.BurstEffect;
	import com.company.assembleegameclient.objects.particles.CollapseEffect;
	import com.company.assembleegameclient.objects.particles.ConeBlastEffect;
	import com.company.assembleegameclient.objects.particles.FlowEffect;
	import com.company.assembleegameclient.objects.particles.HealEffect;
	import com.company.assembleegameclient.objects.particles.LightningEffect;
	import com.company.assembleegameclient.objects.particles.LineEffect;
	import com.company.assembleegameclient.objects.particles.NovaEffect;
	import com.company.assembleegameclient.objects.particles.ParticleEffect;
	import com.company.assembleegameclient.objects.particles.PoisonEffect;
	import com.company.assembleegameclient.objects.particles.RingEffect;
	import com.company.assembleegameclient.objects.particles.RisingFuryEffect;
	import com.company.assembleegameclient.objects.particles.ShockeeEffect;
	import com.company.assembleegameclient.objects.particles.ShockerEffect;
	import com.company.assembleegameclient.objects.particles.StreamEffect;
	import com.company.assembleegameclient.objects.particles.TeleportEffect;
	import com.company.assembleegameclient.objects.particles.ThrowEffect;
	import com.company.assembleegameclient.objects.thrown.ThrowProjectileEffect;
	import com.company.assembleegameclient.parameters.Parameters;
	import com.company.assembleegameclient.screens.charrects.CurrentCharacterRect;
	import com.company.assembleegameclient.sound.SoundEffectLibrary;
	import com.company.assembleegameclient.ui.PicView;
	import com.company.assembleegameclient.ui.dialogs.Dialog;
	import com.company.assembleegameclient.ui.dialogs.NotEnoughFameDialog;
	import com.company.assembleegameclient.ui.panels.GuildInvitePanel;
	import com.company.assembleegameclient.ui.panels.TradeRequestPanel;
	import com.company.assembleegameclient.util.AnimatedChars;
	import com.company.assembleegameclient.util.AssetLoader;
	import com.company.assembleegameclient.util.ConditionEffect;
	import com.company.assembleegameclient.util.Currency;
	import com.company.assembleegameclient.util.FreeList;
	import com.company.assembleegameclient.util.RandomUtil;
	import com.company.util.MoreStringUtil;
	import com.company.util.PointUtil;
	import com.company.util.Random;
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.rsa.RSAKey;
	import com.hurlant.crypto.symmetric.ICipher;
	import com.hurlant.util.Base64;
	import com.hurlant.util.der.PEM;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import io.decagames.rotmg.characterMetrics.tracker.CharactersMetricsTracker;
	import io.decagames.rotmg.classes.NewClassUnlockSignal;
	import io.decagames.rotmg.dailyQuests.messages.incoming.QuestFetchResponse;
	import io.decagames.rotmg.dailyQuests.signal.QuestFetchCompleteSignal;
	import io.decagames.rotmg.dailyQuests.signal.QuestRedeemCompleteSignal;
	import io.decagames.rotmg.pets.data.PetsModel;
	import io.decagames.rotmg.pets.data.vo.HatchPetVO;
	import io.decagames.rotmg.pets.signals.DeletePetSignal;
	import io.decagames.rotmg.pets.signals.HatchPetSignal;
	import io.decagames.rotmg.pets.signals.NewAbilitySignal;
	import io.decagames.rotmg.pets.signals.PetFeedResultSignal;
	import io.decagames.rotmg.pets.signals.UpdateActivePet;
	import io.decagames.rotmg.pets.signals.UpdatePetYardSignal;
	import io.decagames.rotmg.social.model.SocialModel;

	import kabam.lib.net.api.MessageMap;
	import kabam.lib.net.api.MessageProvider;
	import kabam.lib.net.impl.Message;
	import kabam.lib.net.impl.SocketServer;
	import kabam.rotmg.account.core.Account;
	import kabam.rotmg.account.core.view.PurchaseConfirmationDialog;
	import kabam.rotmg.arena.control.ArenaDeathSignal;
	import kabam.rotmg.arena.control.ImminentArenaWaveSignal;
	import kabam.rotmg.arena.model.CurrentArenaRunModel;
	import kabam.rotmg.arena.view.BattleSummaryDialog;
	import kabam.rotmg.arena.view.ContinueOrQuitDialog;
	import kabam.rotmg.chat.model.ChatMessage;
	import kabam.rotmg.classes.model.CharacterClass;
	import kabam.rotmg.classes.model.CharacterSkin;
	import kabam.rotmg.classes.model.CharacterSkinState;
	import kabam.rotmg.classes.model.ClassesModel;
	import kabam.rotmg.constants.GeneralConstants;
	import kabam.rotmg.constants.ItemConstants;
	import kabam.rotmg.core.StaticInjectorContext;
	import kabam.rotmg.dailyLogin.message.ClaimDailyRewardMessage;
	import kabam.rotmg.dailyLogin.message.ClaimDailyRewardResponse;
	import kabam.rotmg.dailyLogin.signal.ClaimDailyRewardResponseSignal;
	import kabam.rotmg.death.control.HandleDeathSignal;
	import kabam.rotmg.death.control.ZombifySignal;
	import kabam.rotmg.dialogs.control.CloseDialogsSignal;
	import kabam.rotmg.dialogs.control.OpenDialogSignal;
	import kabam.rotmg.game.focus.control.SetGameFocusSignal;
	import kabam.rotmg.game.model.GameModel;
	import kabam.rotmg.game.model.PotionInventoryModel;
	import kabam.rotmg.game.signals.AddSpeechBalloonSignal;
	import kabam.rotmg.game.signals.AddTextLineSignal;
	import kabam.rotmg.game.signals.GiftStatusUpdateSignal;
	import kabam.rotmg.maploading.signals.ChangeMapSignal;
	import kabam.rotmg.maploading.signals.HideMapLoadingSignal;
	import kabam.rotmg.messaging.impl.data.GroundTileData;
	import kabam.rotmg.messaging.impl.data.ObjectData;
	import kabam.rotmg.messaging.impl.data.ObjectStatusData;
	import kabam.rotmg.messaging.impl.data.SlotObjectData;
	import kabam.rotmg.messaging.impl.data.StatData;
	import kabam.rotmg.messaging.impl.incoming.AccountList;
	import kabam.rotmg.messaging.impl.incoming.AllyShoot;
	import kabam.rotmg.messaging.impl.incoming.Aoe;
	import kabam.rotmg.messaging.impl.incoming.BuyResult;
	import kabam.rotmg.messaging.impl.incoming.ClientStat;
	import kabam.rotmg.messaging.impl.incoming.CreateSuccess;
	import kabam.rotmg.messaging.impl.incoming.Damage;
	import kabam.rotmg.messaging.impl.incoming.Death;
	import kabam.rotmg.messaging.impl.incoming.EnemyShoot;
	import kabam.rotmg.messaging.impl.incoming.EvolvedMessageHandler;
	import kabam.rotmg.messaging.impl.incoming.EvolvedPetMessage;
	import kabam.rotmg.messaging.impl.incoming.Failure;
	import kabam.rotmg.messaging.impl.incoming.File;
	import kabam.rotmg.messaging.impl.incoming.GlobalNotification;
	import kabam.rotmg.messaging.impl.incoming.Goto;
	import kabam.rotmg.messaging.impl.incoming.GuildResult;
	import kabam.rotmg.messaging.impl.incoming.InvResult;
	import kabam.rotmg.messaging.impl.incoming.InvitedToGuild;
	import kabam.rotmg.messaging.impl.incoming.KeyInfoResponse;
	import kabam.rotmg.messaging.impl.incoming.MapInfo;
	import kabam.rotmg.messaging.impl.incoming.NameResult;
	import kabam.rotmg.messaging.impl.incoming.NewAbilityMessage;
	import kabam.rotmg.messaging.impl.incoming.NewTick;
	import kabam.rotmg.messaging.impl.incoming.Notification;
	import kabam.rotmg.messaging.impl.incoming.PasswordPrompt;
	import kabam.rotmg.messaging.impl.incoming.Pic;
	import kabam.rotmg.messaging.impl.incoming.Ping;
	import kabam.rotmg.messaging.impl.incoming.PlaySound;
	import kabam.rotmg.messaging.impl.incoming.QuestObjId;
	import kabam.rotmg.messaging.impl.incoming.QuestRedeemResponse;
	import kabam.rotmg.messaging.impl.incoming.Reconnect;
	import kabam.rotmg.messaging.impl.incoming.ReskinUnlock;
	import kabam.rotmg.messaging.impl.incoming.ServerPlayerShoot;
	import kabam.rotmg.messaging.impl.incoming.ShowEffect;
	import kabam.rotmg.messaging.impl.incoming.TradeAccepted;
	import kabam.rotmg.messaging.impl.incoming.TradeChanged;
	import kabam.rotmg.messaging.impl.incoming.TradeDone;
	import kabam.rotmg.messaging.impl.incoming.TradeRequested;
	import kabam.rotmg.messaging.impl.incoming.TradeStart;
	import kabam.rotmg.messaging.impl.incoming.Update;
	import kabam.rotmg.messaging.impl.incoming.VerifyEmail;
	import kabam.rotmg.messaging.impl.incoming.arena.ArenaDeath;
	import kabam.rotmg.messaging.impl.incoming.arena.ImminentArenaWave;
	import kabam.rotmg.messaging.impl.incoming.pets.DeletePetMessage;
	import kabam.rotmg.messaging.impl.incoming.pets.HatchPetMessage;
	import kabam.rotmg.messaging.impl.outgoing.AcceptTrade;
	import kabam.rotmg.messaging.impl.outgoing.ActivePetUpdateRequest;
	import kabam.rotmg.messaging.impl.outgoing.AoeAck;
	import kabam.rotmg.messaging.impl.outgoing.Buy;
	import kabam.rotmg.messaging.impl.outgoing.CancelTrade;
	import kabam.rotmg.messaging.impl.outgoing.ChangeGuildRank;
	import kabam.rotmg.messaging.impl.outgoing.ChangePetSkin;
	import kabam.rotmg.messaging.impl.outgoing.ChangeTrade;
	import kabam.rotmg.messaging.impl.outgoing.CheckCredits;
	import kabam.rotmg.messaging.impl.outgoing.ChooseName;
	import kabam.rotmg.messaging.impl.outgoing.Create;
	import kabam.rotmg.messaging.impl.outgoing.CreateGuild;
	import kabam.rotmg.messaging.impl.outgoing.EditAccountList;
	import kabam.rotmg.messaging.impl.outgoing.EnemyHit;
	import kabam.rotmg.messaging.impl.outgoing.Escape;
	import kabam.rotmg.messaging.impl.outgoing.GoToQuestRoom;
	import kabam.rotmg.messaging.impl.outgoing.GotoAck;
	import kabam.rotmg.messaging.impl.outgoing.GroundDamage;
	import kabam.rotmg.messaging.impl.outgoing.GuildInvite;
	import kabam.rotmg.messaging.impl.outgoing.GuildRemove;
	import kabam.rotmg.messaging.impl.outgoing.Hello;
	import kabam.rotmg.messaging.impl.outgoing.InvDrop;
	import kabam.rotmg.messaging.impl.outgoing.InvSwap;
	import kabam.rotmg.messaging.impl.outgoing.JoinGuild;
	import kabam.rotmg.messaging.impl.outgoing.KeyInfoRequest;
	import kabam.rotmg.messaging.impl.outgoing.Load;
	import kabam.rotmg.messaging.impl.outgoing.Move;
	import kabam.rotmg.messaging.impl.outgoing.OtherHit;
	import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;
	import kabam.rotmg.messaging.impl.outgoing.PlayerHit;
	import kabam.rotmg.messaging.impl.outgoing.PlayerShoot;
	import kabam.rotmg.messaging.impl.outgoing.PlayerText;
	import kabam.rotmg.messaging.impl.outgoing.Pong;
	import kabam.rotmg.messaging.impl.outgoing.RequestTrade;
	import kabam.rotmg.messaging.impl.outgoing.Reskin;
	import kabam.rotmg.messaging.impl.outgoing.SetCondition;
	import kabam.rotmg.messaging.impl.outgoing.ShootAck;
	import kabam.rotmg.messaging.impl.outgoing.SquareHit;
	import kabam.rotmg.messaging.impl.outgoing.Teleport;
	import kabam.rotmg.messaging.impl.outgoing.UseItem;
	import kabam.rotmg.messaging.impl.outgoing.UsePortal;
	import kabam.rotmg.messaging.impl.outgoing.arena.EnterArena;
	import kabam.rotmg.messaging.impl.outgoing.arena.QuestRedeem;
	import kabam.rotmg.minimap.control.UpdateGameObjectTileSignal;
	import kabam.rotmg.minimap.control.UpdateGroundTileSignal;
	import kabam.rotmg.minimap.model.UpdateGroundTileVO;
	import kabam.rotmg.servers.api.Server;
	import kabam.rotmg.text.model.TextKey;
	import kabam.rotmg.text.view.stringBuilder.LineBuilder;
	import kabam.rotmg.ui.model.Key;
	import kabam.rotmg.ui.model.UpdateGameObjectTileVO;
	import kabam.rotmg.ui.signals.ShowHideKeyUISignal;
	import kabam.rotmg.ui.signals.ShowKeySignal;
	import kabam.rotmg.ui.signals.UpdateBackpackTabSignal;
	import kabam.rotmg.ui.view.NotEnoughGoldDialog;
	import kabam.rotmg.ui.view.TitleView;

	import org.swiftsuspenders.Injector;

	import robotlegs.bender.framework.api.ILogger;

	public class GameServerConnectionConcrete extends GameServerConnection
		{

			private static const TO_MILLISECONDS:int = 1000;

			private var petUpdater:PetUpdater;
			private var messages:MessageProvider;
			private var player:Player;
			private var retryConnection_:Boolean = true;
			private var rand_:Random = null;
			private var giftChestUpdateSignal:GiftStatusUpdateSignal;
			private var death:Death;
			private var retryTimer_:Timer;
			private var delayBeforeReconnect:int = 2;
			private var addTextLine:AddTextLineSignal;
			private var addSpeechBalloon:AddSpeechBalloonSignal;
			private var updateGroundTileSignal:UpdateGroundTileSignal;
			private var updateGameObjectTileSignal:UpdateGameObjectTileSignal;
			private var logger:ILogger;
			private var handleDeath:HandleDeathSignal;
			private var zombify:ZombifySignal;
			private var setGameFocus:SetGameFocusSignal;
			private var updateBackpackTab:UpdateBackpackTabSignal;
			private var petFeedResult:PetFeedResultSignal;
			private var closeDialogs:CloseDialogsSignal;
			private var openDialog:OpenDialogSignal;
			private var arenaDeath:ArenaDeathSignal;
			private var imminentWave:ImminentArenaWaveSignal;
			private var questFetchComplete:QuestFetchCompleteSignal;
			private var questRedeemComplete:QuestRedeemCompleteSignal;
			private var keyInfoResponse:KeyInfoResponseSignal;
			private var claimDailyRewardResponse:ClaimDailyRewardResponseSignal;
			private var newClassUnlockSignal:NewClassUnlockSignal;
			private var currentArenaRun:CurrentArenaRunModel;
			private var classesModel:ClassesModel;
			private var injector:Injector;
			private var model:GameModel;
			private var updateActivePet:UpdateActivePet;
			private var petsModel:PetsModel;
			private var socialModel:SocialModel;
			private var statsTracker:CharactersMetricsTracker;

			public function GameServerConnectionConcrete(_arg_1:AGameSprite, _arg_2:Server, _arg_3:int, _arg_4:Boolean, _arg_5:int, _arg_6:int, _arg_7:ByteArray, _arg_8:String, _arg_9:Boolean)
			{
				this.injector = StaticInjectorContext.getInjector();
				this.giftChestUpdateSignal = this.injector.getInstance(GiftStatusUpdateSignal);
				this.addTextLine = this.injector.getInstance(AddTextLineSignal);
				this.addSpeechBalloon = this.injector.getInstance(AddSpeechBalloonSignal);
				this.updateGroundTileSignal = this.injector.getInstance(UpdateGroundTileSignal);
				this.updateGameObjectTileSignal = this.injector.getInstance(UpdateGameObjectTileSignal);
				this.petFeedResult = this.injector.getInstance(PetFeedResultSignal);
				this.updateBackpackTab = StaticInjectorContext.getInjector().getInstance(UpdateBackpackTabSignal);
				this.updateActivePet = this.injector.getInstance(UpdateActivePet);
				this.petsModel = this.injector.getInstance(PetsModel);
				this.socialModel = this.injector.getInstance(SocialModel);
				this.closeDialogs = this.injector.getInstance(CloseDialogsSignal);
				changeMapSignal = this.injector.getInstance(ChangeMapSignal);
				this.openDialog = this.injector.getInstance(OpenDialogSignal);
				this.arenaDeath = this.injector.getInstance(ArenaDeathSignal);
				this.imminentWave = this.injector.getInstance(ImminentArenaWaveSignal);
				this.questFetchComplete = this.injector.getInstance(QuestFetchCompleteSignal);
				this.questRedeemComplete = this.injector.getInstance(QuestRedeemCompleteSignal);
				this.keyInfoResponse = this.injector.getInstance(KeyInfoResponseSignal);
				this.claimDailyRewardResponse = this.injector.getInstance(ClaimDailyRewardResponseSignal);
				this.newClassUnlockSignal = this.injector.getInstance(NewClassUnlockSignal);
				this.statsTracker = this.injector.getInstance(CharactersMetricsTracker);
				this.logger = this.injector.getInstance(ILogger);
				this.handleDeath = this.injector.getInstance(HandleDeathSignal);
				this.zombify = this.injector.getInstance(ZombifySignal);
				this.setGameFocus = this.injector.getInstance(SetGameFocusSignal);
				this.classesModel = this.injector.getInstance(ClassesModel);
				serverConnection = this.injector.getInstance(SocketServer);
				this.messages = this.injector.getInstance(MessageProvider);
				this.model = this.injector.getInstance(GameModel);
				this.currentArenaRun = this.injector.getInstance(CurrentArenaRunModel);
				gs_ = _arg_1;
				server_ = _arg_2;
				gameId_ = _arg_3;
				createCharacter_ = _arg_4;
				charId_ = _arg_5;
				keyTime_ = _arg_6;
				key_ = _arg_7;
				mapJSON_ = _arg_8;
				isFromArena_ = _arg_9;
				this.socialModel.loadInvitations();
				this.socialModel.setCurrentServer(server_);
				this.getPetUpdater();
				instance = this;
			}

			private static function isStatPotion(_arg_1:int):Boolean
			{
				return (((((((((((_arg_1 == 2591) || (_arg_1 == 5465)) || (_arg_1 == 9064)) || (((_arg_1 == 2592) || (_arg_1 == 5466)) || (_arg_1 == 9065))) || (((_arg_1 == 2593) || (_arg_1 == 5467)) || (_arg_1 == 9066))) || (((_arg_1 == 2612) || (_arg_1 == 5468)) || (_arg_1 == 9067))) || (((_arg_1 == 2613) || (_arg_1 == 5469)) || (_arg_1 == 9068))) || (((_arg_1 == 2636) || (_arg_1 == 5470)) || (_arg_1 == 9069))) || (((_arg_1 == 2793) || (_arg_1 == 5471)) || (_arg_1 == 9070))) || (((_arg_1 == 2794) || (_arg_1 == 5472)) || (_arg_1 == 9071))) || ((((((((_arg_1 == 9724) || (_arg_1 == 9725)) || (_arg_1 == 9726)) || (_arg_1 == 9727)) || (_arg_1 == 0x2600)) || (_arg_1 == 9729)) || (_arg_1 == 9730)) || (_arg_1 == 9731)));
			}


			private function getPetUpdater():void
			{
				this.injector.map(AGameSprite).toValue(gs_);
				this.petUpdater = this.injector.getInstance(PetUpdater);
				this.injector.unmap(AGameSprite);
			}

			override public function disconnect():void
			{
				this.removeServerConnectionListeners();
				this.unmapMessages();
				serverConnection.disconnect();
			}

			private function removeServerConnectionListeners():void
			{
				serverConnection.connected.remove(this.onConnected);
				serverConnection.closed.remove(this.onClosed);
				serverConnection.error.remove(this.onError);
			}

			override public function connect():void
			{
				this.addServerConnectionListeners();
				this.mapMessages();
				var _local_1:ChatMessage = new ChatMessage();
				_local_1.name = Parameters.CLIENT_CHAT_NAME;
				_local_1.text = TextKey.CHAT_CONNECTING_TO;
				var _local_2:String = server_.name;
				if (_local_2 == '{"text":"server.vault"}')
				{
					_local_2 = "server.vault";
				}
				_local_2 = LineBuilder.getLocalizedStringFromKey(_local_2);
				_local_1.tokens = {"serverName": _local_2};
				this.addTextLine.dispatch(_local_1);
				serverConnection.connect(server_.address, server_.port);
			}

			public function addServerConnectionListeners():void
			{
				serverConnection.connected.add(this.onConnected);
				serverConnection.closed.add(this.onClosed);
				serverConnection.error.add(this.onError);
			}

			public function mapMessages():void
			{
				var local1:MessageMap = this.injector.getInstance(MessageMap);
				local1.map(CREATE).toMessage(Create);
				local1.map(PLAYERSHOOT).toMessage(PlayerShoot);
				local1.map(MOVE).toMessage(Move);
				local1.map(PLAYERTEXT).toMessage(PlayerText);
				local1.map(UPDATEACK).toMessage(Message);
				local1.map(INVSWAP).toMessage(InvSwap);
				local1.map(USEITEM).toMessage(UseItem);
				local1.map(HELLO).toMessage(Hello);
				local1.map(INVDROP).toMessage(InvDrop);
				local1.map(PONG).toMessage(Pong);
				local1.map(LOAD).toMessage(Load);
				local1.map(SETCONDITION).toMessage(SetCondition);
				local1.map(TELEPORT).toMessage(Teleport);
				local1.map(USEPORTAL).toMessage(UsePortal);
				local1.map(BUY).toMessage(Buy);
				local1.map(PLAYERHIT).toMessage(PlayerHit);
				local1.map(ENEMYHIT).toMessage(EnemyHit);
				local1.map(AOEACK).toMessage(AoeAck);
				local1.map(SHOOTACK).toMessage(ShootAck);
				local1.map(OTHERHIT).toMessage(OtherHit);
				local1.map(SQUAREHIT).toMessage(SquareHit);
				local1.map(GOTOACK).toMessage(GotoAck);
				local1.map(GROUNDDAMAGE).toMessage(GroundDamage);
				local1.map(CHOOSENAME).toMessage(ChooseName);
				local1.map(CREATEGUILD).toMessage(CreateGuild);
				local1.map(GUILDREMOVE).toMessage(GuildRemove);
				local1.map(GUILDINVITE).toMessage(GuildInvite);
				local1.map(REQUESTTRADE).toMessage(RequestTrade);
				local1.map(CHANGETRADE).toMessage(ChangeTrade);
				local1.map(ACCEPTTRADE).toMessage(AcceptTrade);
				local1.map(CANCELTRADE).toMessage(CancelTrade);
				local1.map(CHECKCREDITS).toMessage(CheckCredits);
				local1.map(ESCAPE).toMessage(Escape);
				local1.map(QUESTROOMMSG).toMessage(GoToQuestRoom);
				local1.map(JOINGUILD).toMessage(JoinGuild);
				local1.map(CHANGEGUILDRANK).toMessage(ChangeGuildRank);
				local1.map(EDITACCOUNTLIST).toMessage(EditAccountList);
				local1.map(ACTIVEPETUPDATEREQUEST).toMessage(ActivePetUpdateRequest);
				local1.map(PETUPGRADEREQUEST).toMessage(PetUpgradeRequest);
				local1.map(ENTERARENA).toMessage(EnterArena);
				local1.map(ACCEPTARENADEATH).toMessage(OutgoingMessage);
				local1.map(QUESTFETCHASK).toMessage(OutgoingMessage);
				local1.map(QUESTREDEEM).toMessage(QuestRedeem);
				local1.map(KEYINFOREQUEST).toMessage(KeyInfoRequest);
				local1.map(PETCHANGEFORMMSG).toMessage(ReskinPet);
				local1.map(CLAIMLOGINREWARDMSG).toMessage(ClaimDailyRewardMessage);
				local1.map(PETCHANGESKINMSG).toMessage(ChangePetSkin);
				local1.map(FAILURE).toMessage(Failure).toMethod(this.onFailure);
				local1.map(CREATESUCCESS).toMessage(CreateSuccess).toMethod(this.onCreateSuccess);
				local1.map(SERVERPLAYERSHOOT).toMessage(ServerPlayerShoot).toMethod(this.onServerPlayerShoot);
				local1.map(DAMAGE).toMessage(Damage).toMethod(this.onDamage);
				local1.map(UPDATE).toMessage(Update).toMethod(this.onUpdate);
				local1.map(NOTIFICATION).toMessage(Notification).toMethod(this.onNotification);
				local1.map(GLOBALNOTIFICATION).toMessage(GlobalNotification).toMethod(this.onGlobalNotification);
				local1.map(NEWTICK).toMessage(NewTick).toMethod(this.onNewTick);
				local1.map(SHOWEFFECT).toMessage(ShowEffect).toMethod(this.onShowEffect);
				local1.map(GOTO).toMessage(Goto).toMethod(this.onGoto);
				local1.map(INVRESULT).toMessage(InvResult).toMethod(this.onInvResult);
				local1.map(RECONNECT).toMessage(Reconnect).toMethod(this.onReconnect);
				local1.map(PING).toMessage(Ping).toMethod(this.onPing);
				local1.map(MAPINFO).toMessage(MapInfo).toMethod(this.onMapInfo);
				local1.map(PIC).toMessage(Pic).toMethod(this.onPic);
				local1.map(DEATH).toMessage(Death).toMethod(this.onDeath);
				local1.map(BUYRESULT).toMessage(BuyResult).toMethod(this.onBuyResult);
				local1.map(AOE).toMessage(Aoe).toMethod(this.onAoe);
				local1.map(ACCOUNTLIST).toMessage(AccountList).toMethod(this.onAccountList);
				local1.map(QUESTOBJID).toMessage(QuestObjId).toMethod(this.onQuestObjId);
				local1.map(NAMERESULT).toMessage(NameResult).toMethod(this.onNameResult);
				local1.map(GUILDRESULT).toMessage(GuildResult).toMethod(this.onGuildResult);
				local1.map(ALLYSHOOT).toMessage(AllyShoot).toMethod(this.onAllyShoot);
				local1.map(ENEMYSHOOT).toMessage(EnemyShoot).toMethod(this.onEnemyShoot);
				local1.map(TRADEREQUESTED).toMessage(TradeRequested).toMethod(this.onTradeRequested);
				local1.map(TRADESTART).toMessage(TradeStart).toMethod(this.onTradeStart);
				local1.map(TRADECHANGED).toMessage(TradeChanged).toMethod(this.onTradeChanged);
				local1.map(TRADEDONE).toMessage(TradeDone).toMethod(this.onTradeDone);
				local1.map(TRADEACCEPTED).toMessage(TradeAccepted).toMethod(this.onTradeAccepted);
				local1.map(CLIENTSTAT).toMessage(ClientStat).toMethod(this.onClientStat);
				local1.map(FILE).toMessage(File).toMethod(this.onFile);
				local1.map(INVITEDTOGUILD).toMessage(InvitedToGuild).toMethod(this.onInvitedToGuild);
				local1.map(PLAYSOUND).toMessage(PlaySound).toMethod(this.onPlaySound);
				local1.map(ACTIVEPETUPDATE).toMessage(ActivePet).toMethod(this.onActivePetUpdate);
				local1.map(NEWABILITY).toMessage(NewAbilityMessage).toMethod(this.onNewAbility);
				local1.map(PETYARDUPDATE).toMessage(PetYard).toMethod(this.onPetYardUpdate);
				local1.map(EVOLVEPET).toMessage(EvolvedPetMessage).toMethod(this.onEvolvedPet);
				local1.map(DELETEPET).toMessage(DeletePetMessage).toMethod(this.onDeletePet);
				local1.map(HATCHPET).toMessage(HatchPetMessage).toMethod(this.onHatchPet);
				local1.map(IMMINENTARENAWAVE).toMessage(ImminentArenaWave).toMethod(this.onImminentArenaWave);
				local1.map(ARENADEATH).toMessage(ArenaDeath).toMethod(this.onArenaDeath);
				local1.map(VERIFYEMAIL).toMessage(VerifyEmail).toMethod(this.onVerifyEmail);
				local1.map(RESKINUNLOCK).toMessage(ReskinUnlock).toMethod(this.onReskinUnlock);
				local1.map(PASSWORDPROMPT).toMessage(PasswordPrompt).toMethod(this.onPasswordPrompt);
				local1.map(QUESTFETCHRESPONSE).toMessage(QuestFetchResponse).toMethod(this.onQuestFetchResponse);
				local1.map(QUESTREDEEMRESPONSE).toMessage(QuestRedeemResponse).toMethod(this.onQuestRedeemResponse);
				local1.map(KEYINFORESPONSE).toMessage(KeyInfoResponse).toMethod(this.onKeyInfoResponse);
				local1.map(LOGINREWARDMSG).toMessage(ClaimDailyRewardResponse).toMethod(this.onLoginRewardResponse);
			}

			private function onHatchPet(_arg_1:HatchPetMessage):void
			{
				var _local_2:HatchPetSignal = this.injector.getInstance(HatchPetSignal);
				var _local_3:HatchPetVO = new HatchPetVO();
				_local_3.itemType = _arg_1.itemType;
				_local_3.petSkin = _arg_1.petSkin;
				_local_3.petName = _arg_1.petName;
				_local_2.dispatch(_local_3);
			}

			private function onDeletePet(_arg_1:DeletePetMessage):void
			{
				var _local_2:DeletePetSignal = this.injector.getInstance(DeletePetSignal);
				this.injector.getInstance(PetsModel).deletePet(_arg_1.petID);
				_local_2.dispatch(_arg_1.petID);
			}

			private function onNewAbility(_arg_1:NewAbilityMessage):void
			{
				var _local_2:NewAbilitySignal = this.injector.getInstance(NewAbilitySignal);
				_local_2.dispatch(_arg_1.type);
			}

			private function onPetYardUpdate(_arg_1:PetYard):void
			{
				var _local_2:UpdatePetYardSignal = StaticInjectorContext.getInjector().getInstance(UpdatePetYardSignal);
				_local_2.dispatch(_arg_1.type);
			}

			private function onEvolvedPet(_arg_1:EvolvedPetMessage):void
			{
				var _local_2:EvolvedMessageHandler = this.injector.getInstance(EvolvedMessageHandler);
				_local_2.handleMessage(_arg_1);
			}

			private function onActivePetUpdate(_arg_1:ActivePet):void
			{
				this.updateActivePet.dispatch(_arg_1.instanceID);
				var _local_2:String = ((_arg_1.instanceID > 0) ? this.petsModel.getPet(_arg_1.instanceID).name : "");
				var _local_3:String = ((_arg_1.instanceID < 0) ? TextKey.PET_NOT_FOLLOWING : TextKey.PET_FOLLOWING);
				this.addTextLine.dispatch(ChatMessage.make(Parameters.SERVER_CHAT_NAME, _local_3, -1, -1, "", false, {"petName": _local_2}));
			}

			private function unmapMessages():void
			{
				var local1:MessageMap = this.injector.getInstance(MessageMap);
				local1.unmap(CREATE);
				local1.unmap(PLAYERSHOOT);
				local1.unmap(MOVE);
				local1.unmap(PLAYERTEXT);
				local1.unmap(UPDATEACK);
				local1.unmap(INVSWAP);
				local1.unmap(USEITEM);
				local1.unmap(HELLO);
				local1.unmap(INVDROP);
				local1.unmap(PONG);
				local1.unmap(LOAD);
				local1.unmap(SETCONDITION);
				local1.unmap(TELEPORT);
				local1.unmap(USEPORTAL);
				local1.unmap(BUY);
				local1.unmap(PLAYERHIT);
				local1.unmap(ENEMYHIT);
				local1.unmap(AOEACK);
				local1.unmap(SHOOTACK);
				local1.unmap(OTHERHIT);
				local1.unmap(SQUAREHIT);
				local1.unmap(GOTOACK);
				local1.unmap(GROUNDDAMAGE);
				local1.unmap(CHOOSENAME);
				local1.unmap(CREATEGUILD);
				local1.unmap(GUILDREMOVE);
				local1.unmap(GUILDINVITE);
				local1.unmap(REQUESTTRADE);
				local1.unmap(CHANGETRADE);
				local1.unmap(ACCEPTTRADE);
				local1.unmap(CANCELTRADE);
				local1.unmap(CHECKCREDITS);
				local1.unmap(ESCAPE);
				local1.unmap(QUESTROOMMSG);
				local1.unmap(JOINGUILD);
				local1.unmap(CHANGEGUILDRANK);
				local1.unmap(EDITACCOUNTLIST);
				local1.unmap(FAILURE);
				local1.unmap(CREATESUCCESS);
				local1.unmap(SERVERPLAYERSHOOT);
				local1.unmap(DAMAGE);
				local1.unmap(UPDATE);
				local1.unmap(NOTIFICATION);
				local1.unmap(GLOBALNOTIFICATION);
				local1.unmap(NEWTICK);
				local1.unmap(SHOWEFFECT);
				local1.unmap(GOTO);
				local1.unmap(INVRESULT);
				local1.unmap(RECONNECT);
				local1.unmap(PING);
				local1.unmap(MAPINFO);
				local1.unmap(PIC);
				local1.unmap(DEATH);
				local1.unmap(BUYRESULT);
				local1.unmap(AOE);
				local1.unmap(ACCOUNTLIST);
				local1.unmap(QUESTOBJID);
				local1.unmap(NAMERESULT);
				local1.unmap(GUILDRESULT);
				local1.unmap(ALLYSHOOT);
				local1.unmap(ENEMYSHOOT);
				local1.unmap(TRADEREQUESTED);
				local1.unmap(TRADESTART);
				local1.unmap(TRADECHANGED);
				local1.unmap(TRADEDONE);
				local1.unmap(TRADEACCEPTED);
				local1.unmap(CLIENTSTAT);
				local1.unmap(FILE);
				local1.unmap(INVITEDTOGUILD);
				local1.unmap(PLAYSOUND);
			}

			private function encryptConnection():void
			{
				var _local_1:ICipher = Crypto.getCipher("rc4", MoreStringUtil.hexStringToByteArray("6a39570cc9de4ec71d64821894c79332b197f92ba85ed281a023".substring(0, 26)));
				var _local_2:ICipher = Crypto.getCipher("rc4", MoreStringUtil.hexStringToByteArray("6a39570cc9de4ec71d64821894c79332b197f92ba85ed281a023".substring(26)));
				serverConnection.setOutgoingCipher(_local_1);
				serverConnection.setIncomingCipher(_local_2);
			}

			override public function getNextDamage(_arg_1:uint, _arg_2:uint):uint
			{
				return (this.rand_.nextIntRange(_arg_1, _arg_2));
			}

			override public function enableJitterWatcher():void
			{
				if (jitterWatcher_ == null)
				{
					jitterWatcher_ = new JitterWatcher();
				}
			}

			override public function disableJitterWatcher():void
			{
				if (jitterWatcher_ != null)
				{
					jitterWatcher_ = null;
				}
			}

			private function create():void
			{
				var _local_1:CharacterClass = this.classesModel.getSelected();
				var _local_2:Create = (this.messages.require(CREATE) as Create);
				_local_2.classType = _local_1.id;
				_local_2.skinType = _local_1.skins.getSelectedSkin().id;
				serverConnection.sendMessage(_local_2);
				Parameters.Cache_CHARLIST_valid = false;
				Parameters.lockRecon = true;
			}

			private function load():void
			{
				var _local_1:Load = (this.messages.require(LOAD) as Load);
				_local_1.charId_ = charId_;
				_local_1.isFromArena_ = isFromArena_;
				serverConnection.sendMessage(_local_1);
				if (isFromArena_)
				{
					this.openDialog.dispatch(new BattleSummaryDialog());
				}
				Parameters.lockRecon = true;
			}

			override public function playerShoot(_arg_1:int, _arg_2:Projectile):void
			{
				var _local_3:PlayerShoot = (this.messages.require(PLAYERSHOOT) as PlayerShoot);
				_local_3.time_ = _arg_1;
				_local_3.bulletId_ = _arg_2.bulletId_;
				_local_3.containerType_ = _arg_2.containerType_;
				_local_3.startingPos_.x_ = _arg_2.x_;
				_local_3.startingPos_.y_ = _arg_2.y_;
				_local_3.angle_ = _arg_2.angle_;
				serverConnection.sendMessage(_local_3);
			}

			override public function playerHit(_arg_1:int, _arg_2:int):void
			{
				var _local_3:PlayerHit = (this.messages.require(PLAYERHIT) as PlayerHit);
				_local_3.bulletId_ = _arg_1;
				_local_3.objectId_ = _arg_2;
				serverConnection.sendMessage(_local_3);
			}

			override public function enemyHit(_arg_1:int, _arg_2:int, _arg_3:int, _arg_4:Boolean):void
			{
				var _local_5:EnemyHit = (this.messages.require(ENEMYHIT) as EnemyHit);
				_local_5.time_ = _arg_1;
				_local_5.bulletId_ = _arg_2;
				_local_5.targetId_ = _arg_3;
				_local_5.kill_ = _arg_4;
				serverConnection.sendMessage(_local_5);
			}

			override public function otherHit(_arg_1:int, _arg_2:int, _arg_3:int, _arg_4:int):void
			{
				var _local_5:OtherHit = (this.messages.require(OTHERHIT) as OtherHit);
				_local_5.time_ = _arg_1;
				_local_5.bulletId_ = _arg_2;
				_local_5.objectId_ = _arg_3;
				_local_5.targetId_ = _arg_4;
				serverConnection.sendMessage(_local_5);
			}

			override public function squareHit(_arg_1:int, _arg_2:int, _arg_3:int):void
			{
				var _local_4:SquareHit = (this.messages.require(SQUAREHIT) as SquareHit);
				_local_4.time_ = _arg_1;
				_local_4.bulletId_ = _arg_2;
				_local_4.objectId_ = _arg_3;
				serverConnection.sendMessage(_local_4);
			}

			public function aoeAck(_arg_1:int, _arg_2:Number, _arg_3:Number):void
			{
				var _local_4:AoeAck = (this.messages.require(AOEACK) as AoeAck);
				_local_4.time_ = _arg_1;
				_local_4.position_.x_ = _arg_2;
				_local_4.position_.y_ = _arg_3;
				serverConnection.sendMessage(_local_4);
			}

			override public function groundDamage(_arg_1:int, _arg_2:Number, _arg_3:Number):void
			{
				var _local_4:GroundDamage = (this.messages.require(GROUNDDAMAGE) as GroundDamage);
				_local_4.time_ = _arg_1;
				_local_4.position_.x_ = _arg_2;
				_local_4.position_.y_ = _arg_3;
				serverConnection.sendMessage(_local_4);
			}

			public function shootAck(_arg_1:int):void
			{
				var _local_2:ShootAck = (this.messages.require(SHOOTACK) as ShootAck);
				_local_2.time_ = _arg_1;
				serverConnection.sendMessage(_local_2);
			}

			override public function playerText(_arg_1:String):void
			{
				var _local_2:PlayerText = (this.messages.require(PLAYERTEXT) as PlayerText);
				_local_2.text_ = _arg_1;
				serverConnection.sendMessage(_local_2);
			}

			override public function invSwap(_arg_1:Player, _arg_2:GameObject, _arg_3:int, _arg_4:int, _arg_5:GameObject, _arg_6:int, _arg_7:int):Boolean
			{
				if (gs_ == null)
				{
					return (false);
				}
				if ((gs_.lastUpdate_ - this.lastInvSwapTime) < 520)
				{
					return (false);
				}
				var _local_8:InvSwap = (this.messages.require(INVSWAP) as InvSwap);
				_local_8.time_ = gs_.lastUpdate_;
				_local_8.position_.x_ = _arg_1.x_;
				_local_8.position_.y_ = _arg_1.y_;
				_local_8.slotObject1_.objectId_ = _arg_2.objectId_;
				_local_8.slotObject1_.slotId_ = _arg_3;
				_local_8.slotObject1_.objectType_ = _arg_4;
				_local_8.slotObject2_.objectId_ = _arg_5.objectId_;
				_local_8.slotObject2_.slotId_ = _arg_6;
				_local_8.slotObject2_.objectType_ = _arg_7;
				serverConnection.sendMessage(_local_8);
				this.lastInvSwapTime = _local_8.time_;
				var _local_9:int = _arg_2.equipment_[_arg_3];
				_arg_2.equipment_[_arg_3] = _arg_5.equipment_[_arg_6];
				_arg_5.equipment_[_arg_6] = _local_9;
				SoundEffectLibrary.play("inventory_move_item");
				if (_arg_1 == this.gs_.map.player_)
				{
					_arg_1.recalcAllEnemyHighestDps();
				}
				return (true);
			}

			override public function invSwapPotion(_arg_1:Player, _arg_2:GameObject, _arg_3:int, _arg_4:int, _arg_5:GameObject, _arg_6:int, _arg_7:int):Boolean
			{
				if (!gs_)
				{
					return (false);
				}
				if ((this.gs_.lastUpdate_ - this.lastInvSwapTime) < 520)
				{
					return (false);
				}
				var _local_8:InvSwap = (this.messages.require(INVSWAP) as InvSwap);
				_local_8.time_ = gs_.lastUpdate_;
				_local_8.position_.x_ = _arg_1.x_;
				_local_8.position_.y_ = _arg_1.y_;
				_local_8.slotObject1_.objectId_ = _arg_2.objectId_;
				_local_8.slotObject1_.slotId_ = _arg_3;
				_local_8.slotObject1_.objectType_ = _arg_4;
				_local_8.slotObject2_.objectId_ = _arg_5.objectId_;
				_local_8.slotObject2_.slotId_ = _arg_6;
				_local_8.slotObject2_.objectType_ = _arg_7;
				_arg_2.equipment_[_arg_3] = ItemConstants.NO_ITEM;
				if (_arg_4 == PotionInventoryModel.HEALTH_POTION_ID)
				{
					_arg_1.healthPotionCount_++;
				}
				else
				{
					if (_arg_4 == PotionInventoryModel.MAGIC_POTION_ID)
					{
						_arg_1.magicPotionCount_++;
					}
				}
				serverConnection.sendMessage(_local_8);
				this.lastInvSwapTime = _local_8.time_;
				SoundEffectLibrary.play("inventory_move_item");
				if (player == this.gs_.map.player_)
				{
					player.recalcAllEnemyHighestDps();
				}
				return (true);
			}

			override public function invDrop(_arg_1:GameObject, _arg_2:int, _arg_3:int):void
			{
				var _local_4:InvDrop = (this.messages.require(INVDROP) as InvDrop);
				_local_4.slotObject_.objectId_ = _arg_1.objectId_;
				_local_4.slotObject_.slotId_ = _arg_2;
				_local_4.slotObject_.objectType_ = _arg_3;
				serverConnection.sendMessage(_local_4);
				if (_arg_2 != PotionInventoryModel.HEALTH_POTION_SLOT && _arg_2 != PotionInventoryModel.MAGIC_POTION_SLOT)
				{
					_arg_1.equipment_[_arg_2] = ItemConstants.NO_ITEM;
				}
				if (player == this.gs_.map.player_)
				{
					player.recalcAllEnemyHighestDps();
				}
			}

			override public function useItem(_arg_1:int, _arg_2:int, _arg_3:int, _arg_4:int, _arg_5:Number, _arg_6:Number, _arg_7:int):void
			{
				if (Parameters.data_.fameBlockAbility && _arg_2 == this.playerId_ && _arg_3 == 1)
				{
					this.player.textNotification("Ignored ability use, Mundane enabled", 0xE25F00);
					return;
				}
				if (Parameters.data_.fameBlockThirsty && _arg_2 == this.playerId_ && _arg_3 > 3 && _arg_3 < 254)
				{
					var _local_9:ObjectProperties = ObjectLibrary.propsLibrary_[this.player.equipment_[_arg_3]];
					if (_local_9 != null && _local_9.isPotion_)
					{
						this.player.textNotification("Ignored potion use, Thirsty enabled", 0xE25F00);
						return;
					}
				}
				var _local_8:UseItem = (this.messages.require(USEITEM) as UseItem);
				_local_8.time_ = _arg_1;
				_local_8.slotObject_.objectId_ = _arg_2;
				_local_8.slotObject_.slotId_ = _arg_3;
				_local_8.slotObject_.objectType_ = _arg_4;
				_local_8.itemUsePos_.x_ = _arg_5;
				_local_8.itemUsePos_.y_ = _arg_6;
				_local_8.useType_ = _arg_7;
				serverConnection.sendMessage(_local_8);
				if (player == this.gs_.map.player_)
				{
					player.recalcAllEnemyHighestDps();
				}
			}

			override public function useItem_new(_arg_1:GameObject, _arg_2:int):Boolean
			{
				var _local_4:XML;
				var _local_3:int = _arg_1.equipment_[_arg_2];
				if (Parameters.data_.fameBlockAbility && _arg_1.objectId_ == this.playerId_ && _arg_2 == 1)
				{
					this.player.textNotification("Ignored ability use, Mundane enabled", 0xE25F00);
					return (false);
				}
				if (Parameters.data_.fameBlockThirsty && _arg_1.objectId_ == this.playerId_ && _arg_2 > 3 && _arg_2 < 254)
				{
					var _local_5:ObjectProperties = ObjectLibrary.propsLibrary_[_arg_1.equipment_[_arg_2]];
					if (_local_5 != null && _local_5.isPotion_)
					{
						this.player.textNotification("Ignored potion use, Thirsty enabled", 0xE25F00);
						return (false);
					}
				}
				if (_arg_1 == null || _arg_1.equipment_ == null)
				{
					return (false);
				}
				if (((_local_3 >= 0x9000) && (_local_3 < 0xF000)))
				{
					_local_4 = ObjectLibrary.xmlLibrary_[36863];
				}
				else
				{
					_local_4 = ObjectLibrary.xmlLibrary_[_local_3];
				}
				if ((_local_4 && !_arg_1.isPaused && _local_4.hasOwnProperty("Consumable")) || _local_4.hasOwnProperty("InvUse"))
				{
					if (!this.validStatInc(_local_3, _arg_1))
					{
						this.addTextLine.dispatch(ChatMessage.make("", (_local_4.attribute("id") + " not consumed. Already at Max.")));
						return (false);
					}
					if (isStatPotion(_local_3))
					{
						this.addTextLine.dispatch(ChatMessage.make("", (_local_4.attribute("id") + " Consumed ++")));
					}
					this.applyUseItem(_arg_1, _arg_2, _local_3, _local_4);
					if (_local_4.hasOwnProperty("Key"))
					{
						SoundEffectLibrary.play("use_key");
					}
					else
					{
						SoundEffectLibrary.play("use_potion");
					}
					return (true);
				}
				if (this.swapEquip(_arg_1, _arg_2, _local_4))
				{
					return (true);
				}
				SoundEffectLibrary.play("error");
				return (false);
			}

			public function swapEquip(_arg_1:GameObject, _arg_2:int, _arg_3:XML):Boolean
			{
				var _local_6:int;
				var _local_4:Vector.<int>;
				var _local_5:int;
				if (_arg_3 && !_arg_1.isPaused && _arg_3.hasOwnProperty("SlotType"))
				{
					_local_6 = _arg_3.SlotType;
					_local_4 = _arg_1.slotTypes_.slice(0, 4);
					var _local_7:int = 0;
					for each (_local_5 in _local_4)
					{
						if (_local_5 == _local_6)
						{
							this.swapItems(_arg_1, _local_7, _arg_2);
							return (true);
						}
						_local_7++;
					}
				}
				return (false);
			}

			public function swapItems(_arg_1:GameObject, _arg_2:int, _arg_3:int):void
			{
				var _local_4:Vector.<int> = _arg_1.equipment_;
				this.invSwap((_arg_1 as Player), _arg_1, _arg_2, _local_4[_arg_2], _arg_1, _arg_3, _local_4[_arg_3]);
			}

			private function validStatInc(itemId:int, itemOwner:GameObject):Boolean
			{
				var p:Player;
				try
				{
					if ((itemOwner is Player))
					{
						p = (itemOwner as Player);
					}
					else
					{
						p = this.player;
					}
					if (((((((((((((itemId == 2591) || (itemId == 5465)) || (itemId == 9064)) || (itemId == 9729)) && (p.attackMax_ == (p.attack_ - p.attackBoost_))) || (((((itemId == 2592) || (itemId == 5466)) || (itemId == 9065)) || (itemId == 9727)) && (p.defenseMax_ == (p.defense_ - p.defenseBoost_)))) || (((((itemId == 2593) || (itemId == 5467)) || (itemId == 9066)) || (itemId == 9726)) && (p.speedMax_ == (p.speed_ - p.speedBoost_)))) || (((((itemId == 2612) || (itemId == 5468)) || (itemId == 9067)) || (itemId == 9724)) && (p.vitalityMax_ == (p.vitality_ - p.vitalityBoost_)))) || (((((itemId == 2613) || (itemId == 5469)) || (itemId == 9068)) || (itemId == 9725)) && (p.wisdomMax_ == (p.wisdom_ - p.wisdomBoost_)))) || (((((itemId == 2636) || (itemId == 5470)) || (itemId == 9069)) || (itemId == 0x2600)) && (p.dexterityMax_ == (p.dexterity_ - p.dexterityBoost_)))) || (((((itemId == 2793) || (itemId == 5471)) || (itemId == 9070)) || (itemId == 9731)) && (p.maxHPMax_ == (p.maxHP_ - p.maxHPBoost_)))) || (((((itemId == 2794) || (itemId == 5472)) || (itemId == 9071)) || (itemId == 9730)) && (p.maxMPMax_ == (p.maxMP_ - p.maxMPBoost_)))))
					{
						return (false);
					}
				}
				catch (err:Error)
				{
					logger.error("PROBLEM IN STAT INC " + err.getStackTrace());
				}
				return (true);
			}

			private function applyUseItem(_arg_1:GameObject, _arg_2:int, _arg_3:int, _arg_4:XML):void
			{
				var _local_5:UseItem = (this.messages.require(USEITEM) as UseItem);
				_local_5.time_ = getTimer();
				_local_5.slotObject_.objectId_ = _arg_1.objectId_;
				_local_5.slotObject_.slotId_ = _arg_2;
				_local_5.slotObject_.objectType_ = _arg_3;
				_local_5.itemUsePos_.x_ = 0;
				_local_5.itemUsePos_.y_ = 0;
				serverConnection.sendMessage(_local_5);
				if (_arg_4.hasOwnProperty("Consumable"))
				{
					_arg_1.equipment_[_arg_2] = -1;
				}
			}

			override public function setCondition(_arg_1:uint, _arg_2:Number):void
			{
				var _local_3:SetCondition = (this.messages.require(SETCONDITION) as SetCondition);
				_local_3.conditionEffect_ = _arg_1;
				_local_3.conditionDuration_ = _arg_2;
				serverConnection.sendMessage(_local_3);
			}

			public function move(_arg_1:int, _arg_2:Player):void
			{
				var _local_7:int;
				var _local_8:int;
				var _local_3:Number = -1;
				var _local_4:Number = -1;
				if (((_arg_2) && (!(_arg_2.isPaused))))
				{
					_local_3 = _arg_2.x_;
					_local_4 = _arg_2.y_;
				}
				var _local_5:Move = (this.messages.require(MOVE) as Move);
				_local_5.tickId_ = _arg_1;
				_local_5.time_ = gs_.lastUpdate_;
				_local_5.newPosition_.x_ = _local_3;
				_local_5.newPosition_.y_ = _local_4;
				var _local_6:int = gs_.moveRecords_.lastClearTime_;
				_local_5.records_.length = 0;
				if (((_local_6 >= 0) && ((_local_5.time_ - _local_6) > 125)))
				{
					_local_7 = Math.min(10, gs_.moveRecords_.records_.length);
					_local_8 = 0;
					while (_local_8 < _local_7)
					{
						if (gs_.moveRecords_.records_[_local_8].time_ >= (_local_5.time_ - 25))
						{
							break;
						}
						_local_5.records_.push(gs_.moveRecords_.records_[_local_8]);
						_local_8++;
					}
				}
				gs_.moveRecords_.clear(_local_5.time_);
				serverConnection.sendMessage(_local_5);
				((_arg_2) && (_arg_2.onMove()));
			}

			override public function teleport(_arg_1:int):void
			{
				if (Parameters.data_.fameBlockTP)
				{
					this.player.textNotification("Ignored teleport, Boots on the Ground enabled", 0xE25F00);
					return;
				}
				var _local_2:Teleport = (this.messages.require(TELEPORT) as Teleport);
				_local_2.objectId_ = _arg_1;
				serverConnection.sendMessage(_local_2);
			}

			override public function usePortal(_arg_1:int):void
			{
				if (Parameters.usingPortal)
				{
					Parameters.portalID = _arg_1;
				}
				var _local_2:UsePortal = (this.messages.require(USEPORTAL) as UsePortal);
				_local_2.objectId_ = _arg_1;
				serverConnection.sendMessage(_local_2);
				this.checkDavyKeyRemoval();
				if (Parameters.fameBot)
				{
					var _local_3:Portal = (this.gs_.map.goDict_[_arg_1] as Portal);
					if (_local_3 && _local_3.getName().indexOf("NexusPortal") != -1)
					{
						Parameters.fameBotPortalId = _arg_1;
						Parameters.fameBotPortal = _local_3;
						Parameters.fameBotPortalPoint = new Point((RandomUtil.plusMinus(0.5) + _local_3.x_), (RandomUtil.plusMinus(0.5) + _local_3.y_));
						this.player.textNotification("Fame Train Realm now set!");
						Parameters.fameBot = true;
						Parameters.fameBotWatchingPortal = false;
					}
				}
			}

			private function checkDavyKeyRemoval():void
			{
				if (gs_.map && gs_.map.name_ == "Davy Jones' Locker")
				{
					ShowHideKeyUISignal.instance.dispatch();
				}
			}

			override public function buy(sellableObjectId:int, quantity:int):void
			{
				var sObj:SellableObject;
				var converted:Boolean;
				if (outstandingBuy_ != null)
				{
					return;
				}
				sObj = gs_.map.goDict_[sellableObjectId];
				if (sObj == null)
				{
					return;
				}
				converted = false;
				if (sObj.currency_ == Currency.GOLD)
				{
					converted = (gs_.model.getConverted() || this.player.credits_ > 100 || sObj.price_ > this.player.credits_);
				}
				if (sObj.soldObjectName() == TextKey.VAULT_CHEST)
				{
					this.openDialog.dispatch(new PurchaseConfirmationDialog(function ():void {
						buyConfirmation(sObj, converted, sellableObjectId, quantity);
					}));
				}
				else
				{
					this.buyConfirmation(sObj, converted, sellableObjectId, quantity);
				}
			}

			private function buyConfirmation(_arg_1:SellableObject, _arg_2:Boolean, _arg_3:int, _arg_4:int):void
			{
				outstandingBuy_ = new OutstandingBuy(_arg_1.soldObjectInternalName(), _arg_1.price_, _arg_1.currency_, _arg_2);
				var _local_5:Buy = (this.messages.require(BUY) as Buy);
				_local_5.objectId_ = _arg_3;
				_local_5.quantity_ = _arg_4;
				serverConnection.sendMessage(_local_5);
			}

			public function gotoAck(_arg_1:int):void
			{
				var _local_2:GotoAck = (this.messages.require(GOTOACK) as GotoAck);
				_local_2.time_ = _arg_1;
				serverConnection.sendMessage(_local_2);
			}

			override public function editAccountList(_arg_1:int, _arg_2:Boolean, _arg_3:int):void
			{
				var _local_4:EditAccountList = (this.messages.require(EDITACCOUNTLIST) as EditAccountList);
				_local_4.accountListId_ = _arg_1;
				_local_4.add_ = _arg_2;
				_local_4.objectId_ = _arg_3;
				serverConnection.sendMessage(_local_4);
			}

			override public function chooseName(_arg_1:String):void
			{
				var _local_2:ChooseName = (this.messages.require(CHOOSENAME) as ChooseName);
				_local_2.name_ = _arg_1;
				serverConnection.sendMessage(_local_2);
			}

			override public function createGuild(_arg_1:String):void
			{
				var _local_2:CreateGuild = (this.messages.require(CREATEGUILD) as CreateGuild);
				_local_2.name_ = _arg_1;
				serverConnection.sendMessage(_local_2);
			}

			override public function guildRemove(_arg_1:String):void
			{
				var _local_2:GuildRemove = (this.messages.require(GUILDREMOVE) as GuildRemove);
				_local_2.name_ = _arg_1;
				serverConnection.sendMessage(_local_2);
			}

			override public function guildInvite(_arg_1:String):void
			{
				var _local_2:GuildInvite = (this.messages.require(GUILDINVITE) as GuildInvite);
				_local_2.name_ = _arg_1;
				serverConnection.sendMessage(_local_2);
			}

			override public function requestTrade(_arg_1:String):void
			{
				var _local_2:RequestTrade = (this.messages.require(REQUESTTRADE) as RequestTrade);
				_local_2.name_ = _arg_1;
				serverConnection.sendMessage(_local_2);
			}

			override public function changeTrade(_arg_1:Vector.<Boolean>):void
			{
				var _local_2:ChangeTrade = (this.messages.require(CHANGETRADE) as ChangeTrade);
				_local_2.offer_ = _arg_1;
				serverConnection.sendMessage(_local_2);
			}

			override public function acceptTrade(_arg_1:Vector.<Boolean>, _arg_2:Vector.<Boolean>):void
			{
				var _local_3:AcceptTrade = (this.messages.require(ACCEPTTRADE) as AcceptTrade);
				_local_3.myOffer_ = _arg_1;
				_local_3.yourOffer_ = _arg_2;
				serverConnection.sendMessage(_local_3);
			}

			override public function cancelTrade():void
			{
				serverConnection.sendMessage(this.messages.require(CANCELTRADE));
			}

			override public function checkCredits():void
			{
				serverConnection.sendMessage(this.messages.require(CHECKCREDITS));
			}

			override public function escape():void
			{
				if (this.playerId_ == -1)
				{
					return;
				}
				if (gs_.map && gs_.map.name_ == "Arena")
				{
					serverConnection.sendMessage(this.messages.require(ACCEPTARENADEATH));
				}
				else
				{
					serverConnection.sendMessage(this.messages.require(ESCAPE));
					this.checkDavyKeyRemoval();
				}
			}

			override public function gotoQuestRoom():void
			{
				serverConnection.sendMessage(this.messages.require(QUESTROOMMSG));
			}

			override public function joinGuild(_arg_1:String):void
			{
				var _local_2:JoinGuild = (this.messages.require(JOINGUILD) as JoinGuild);
				_local_2.guildName_ = _arg_1;
				serverConnection.sendMessage(_local_2);
			}

			override public function changeGuildRank(_arg_1:String, _arg_2:int):void
			{
				var _local_3:ChangeGuildRank = (this.messages.require(CHANGEGUILDRANK) as ChangeGuildRank);
				_local_3.name_ = _arg_1;
				_local_3.guildRank_ = _arg_2;
				serverConnection.sendMessage(_local_3);
			}

			override public function changePetSkin(_arg_1:int, _arg_2:int, _arg_3:int):void
			{
				var _local_4:ChangePetSkin = (this.messages.require(PETCHANGESKINMSG) as ChangePetSkin);
				_local_4.petId = _arg_1;
				_local_4.skinType = _arg_2;
				_local_4.currency = _arg_3;
				serverConnection.sendMessage(_local_4);
			}

			private function rsaEncrypt(_arg_1:String):String
			{
				var _local_2:RSAKey = PEM.readRSAPublicKey(Parameters.RSA_PUBLIC_KEY);
				var _local_3:ByteArray = new ByteArray();
				_local_3.writeUTFBytes(_arg_1);
				var _local_4:ByteArray = new ByteArray();
				_local_2.encrypt(_local_3, _local_4, _local_3.length);
				return (Base64.encodeByteArray(_local_4));
			}

			private function onConnected():void
			{
				var _local_1:Account = StaticInjectorContext.getInjector().getInstance(Account);
				this.addTextLine.dispatch(ChatMessage.make(Parameters.CLIENT_CHAT_NAME, TextKey.CHAT_CONNECTED));
				this.encryptConnection();
				var _local_2:Hello = (this.messages.require(HELLO) as Hello);
				_local_2.buildVersion_ = Parameters.data_.gameVersion;
				_local_2.gameId_ = gameId_;
				if (CurrentCharacterRect.vaultSelect)
				{
					_local_2.gameId_ = Parameters.VAULT_GAMEID;
					CurrentCharacterRect.vaultSelect = false;
				}
				if (Parameters.dailyCalendar1RunOnce)
				{
					_local_2.gameId_ = Parameters.DAILYQUESTROOM_GAMEID;
					Parameters.dailyCalendar1RunOnce = false;
				}
				_local_2.guid_ = this.rsaEncrypt(_local_1.getUserId());
				_local_2.password_ = this.rsaEncrypt(_local_1.getPassword());
				_local_2.secret_ = this.rsaEncrypt(_local_1.getSecret());
				_local_2.keyTime_ = keyTime_;
				_local_2.key_.length = 0;
				(key_ != null && _local_2.key_.writeBytes(key_));
				_local_2.mapJSON_ = ((mapJSON_ == null) ? "" : mapJSON_);
				_local_2.entrytag_ = _local_1.getEntryTag();
				_local_2.gameNet = _local_1.gameNetwork();
				_local_2.gameNetUserId = _local_1.gameNetworkUserId();
				_local_2.playPlatform = _local_1.playPlatform();
				_local_2.platformToken = _local_1.getPlatformToken();
				_local_2.userToken = _local_1.getToken();
				serverConnection.sendMessage(_local_2);
			}

			private function onCreateSuccess(_arg_1:CreateSuccess):void
			{
				this.playerId_ = _arg_1.objectId_;
				charId_ = _arg_1.charId_;
				gs_.initialize();
				createCharacter_ = false;
				Parameters.lockRecon = false;
			}

			private function onDamage(_arg_1:Damage):void
			{
				var _local_5:int;
				var _local_6:Boolean;
				var _local_2:AbstractMap = gs_.map;
				var _local_3:Projectile;
				if (!Parameters.ssmode && Parameters.lowCPUMode)
				{
					if (_arg_1.objectId_ != this.player.objectId_ || _arg_1.targetId_ != this.player.objectId_)
					{
						return;
					}
				}
				if (_arg_1.objectId_ >= 0 && _arg_1.bulletId_ > 0)
				{
					_local_5 = Projectile.findObjId(_arg_1.objectId_, _arg_1.bulletId_);
					_local_3 = (_local_2.boDict_[_local_5] as Projectile);
					if (_local_3 != null && !_local_3.projProps_.multiHit_)
					{
						_local_2.removeObj(_local_5);
					}
				}
				var _local_4:GameObject = _local_2.goDict_[_arg_1.targetId_];
				if (_local_4 != null && _local_4.props_.isEnemy_)
				{
					_local_6 = (_arg_1.objectId_ == this.player.objectId_);
					_local_4.damage(_local_6, _arg_1.damageAmount_, _arg_1.effects_, _arg_1.kill_, _local_3, _arg_1.armorPierce_);
					if (_local_6)
					{
						if (isNaN(Parameters.dmgCounter[_arg_1.targetId_]))
						{
							Parameters.dmgCounter[_arg_1.targetId_] = 0;
						}
						Parameters.dmgCounter[_arg_1.targetId_] = Parameters.dmgCounter[_arg_1.targetId_] + _arg_1.damageAmount_;
					}
				}
			}

			private function onServerPlayerShoot(_arg_1:ServerPlayerShoot):void
			{
				var _local_2:* = (_arg_1.ownerId_ == this.playerId_);
				var _local_3:GameObject = gs_.map.goDict_[_arg_1.ownerId_];
				if (_local_3 == null || _local_3.dead_)
				{
					if (_local_2)
					{
						this.shootAck(-1);
					}
					return;
				}
				if (_local_3.objectId_ != this.playerId_ && Parameters.data_.disableAllyShoot)
				{
					return;
				}
				var _local_4:Projectile = (FreeList.newObject(Projectile) as Projectile);
				var _local_5:Player = (_local_3 as Player);
				if (_local_5 != null)
				{
					_local_4.reset(_arg_1.containerType_, 0, _arg_1.ownerId_, _arg_1.bulletId_, _arg_1.angle_, gs_.lastUpdate_, _local_5.projectileIdSetOverrideNew, _local_5.projectileIdSetOverrideOld);
				}
				else
				{
					_local_4.reset(_arg_1.containerType_, 0, _arg_1.ownerId_, _arg_1.bulletId_, _arg_1.angle_, gs_.lastUpdate_);
				}
				_local_4.setDamage(_arg_1.damage_);
				gs_.map.addObj(_local_4, _arg_1.startingPos_.x_, _arg_1.startingPos_.y_);
				if (_local_2)
				{
					this.shootAck(gs_.lastUpdate_);
					if (!_local_4.update(_local_4.startTime_, 0))
					{
						gs_.map.removeObj(_local_4.objectId_);
					}
				}
			}

			private function onAllyShoot(_arg_1:AllyShoot):void
			{
				var _local_2:GameObject = gs_.map.goDict_[_arg_1.ownerId_];
				if (_local_2 != null)
				{
					if (_local_2.dead_)
					{
						return;
					}
					if (Parameters.data_.disableAllyShoot == 1)
					{
						return;
					}
					_local_2.setAttack(_arg_1.containerType_, _arg_1.angle_);
					if (Parameters.data_.disableAllyShoot == 2)
					{
						return;
					}
					var _local_3:Projectile = (FreeList.newObject(Projectile) as Projectile);
					var _local_4:Player = (_local_2 as Player);
					if (_local_4 != null)
					{
						_local_3.reset(_arg_1.containerType_, 0, _arg_1.ownerId_, _arg_1.bulletId_, _arg_1.angle_, gs_.lastUpdate_, _local_4.projectileIdSetOverrideNew, _local_4.projectileIdSetOverrideOld);
					}
					else
					{
						_local_3.reset(_arg_1.containerType_, 0, _arg_1.ownerId_, _arg_1.bulletId_, _arg_1.angle_, gs_.lastUpdate_);
					}
					gs_.map.addObj(_local_3, _local_2.x_, _local_2.y_);
				}
			}

			private function onReskinUnlock(_arg_1:ReskinUnlock):void
			{
				var _local_2:String;
				var _local_3:CharacterSkin;
				var _local_4:PetsModel;
				if (_arg_1.isPetSkin == 0)
				{
					for (_local_2 in this.model.player.lockedSlot)
					{
						if (this.model.player.lockedSlot[_local_2] == _arg_1.skinID)
						{
							this.model.player.lockedSlot[_local_2] = 0;
						}
					}
					_local_3 = this.classesModel.getCharacterClass(this.model.player.objectType_).skins.getSkin(_arg_1.skinID);
					_local_3.setState(CharacterSkinState.OWNED);
				}
				else
				{
					_local_4 = StaticInjectorContext.getInjector().getInstance(PetsModel);
					_local_4.unlockSkin(_arg_1.skinID);
				}
			}

			private function onEnemyShoot(_arg_1:EnemyShoot):void
			{
				var _local_4:Projectile;
				var _local_5:Number;
				var _local_2:GameObject = gs_.map.goDict_[_arg_1.ownerId_];
				if (_local_2 == null || _local_2.dead_)
				{
					this.shootAck(-1);
					return;
				}
				var _local_3:int;
				while (_local_3 < _arg_1.numShots_)
				{
					_local_4 = (FreeList.newObject(Projectile) as Projectile);
					_local_5 = (_arg_1.angle_ + (_arg_1.angleInc_ * _local_3));
					_local_4.reset(_local_2.objectType_, _arg_1.bulletType_, _arg_1.ownerId_, ((_arg_1.bulletId_ + _local_3) % 0x0100), _local_5, gs_.lastUpdate_);
					_local_4.setDamage(_arg_1.damage_);
					gs_.map.addObj(_local_4, _arg_1.startingPos_.x_, _arg_1.startingPos_.y_);
					_local_3++;
				}
				this.shootAck(gs_.lastUpdate_);
				_local_2.setAttack(_local_2.objectType_, (_arg_1.angle_ + (_arg_1.angleInc_ * ((_arg_1.numShots_ - 1) / 2))));
			}

			private function onTradeRequested(_arg_1:TradeRequested):void
			{
				if (Parameters.autoAcceptTrades || Parameters.receivingPots)
				{
					this.playerText(("/trade " + _arg_1.name_));
					return;
				}
				if (!Parameters.data_.chatTrade)
				{
					return;
				}
				if (Parameters.data_.tradeWithFriends && !this.socialModel.isMyFriend(_arg_1.name_))
				{
					return;
				}
				if (Parameters.data_.showTradePopup)
				{
					gs_.hudView.interactPanel.setOverride(new TradeRequestPanel(gs_, _arg_1.name_));
				}
				this.addTextLine.dispatch(ChatMessage.make("", (_arg_1.name_ + " wants to " + 'trade with you.  Type "/trade ' + _arg_1.name_ + '" to trade.')));
			}

			private function onTradeStart(_arg_1:TradeStart):void
			{
				if (Parameters.givingPotions)
				{
					this.changeTrade(Parameters.potionsToTrade);
					this.acceptTrade(Parameters.potionsToTrade, Parameters.emptyOffer);
					Parameters.givingPotions = false;
				}
				gs_.hudView.startTrade(gs_, _arg_1);
			}

			private function onTradeChanged(_arg_1:TradeChanged):void
			{
				if (Parameters.receivingPots)
				{
					this.acceptTrade(Parameters.emptyOffer, _arg_1.offer_);
					Parameters.receivingPots = false;
				}
				gs_.hudView.tradeChanged(_arg_1);
			}

			private function onTradeDone(_arg_1:TradeDone):void
			{
				var _local_3:Object;
				var _local_4:Object;
				gs_.hudView.tradeDone();
				var _local_2:String = "";
				try
				{
					_local_4 = JSON.parse(_arg_1.description_);
					_local_2 = _local_4.key;
					_local_3 = _local_4.tokens;
				}
				catch (e:Error)
				{
				}
				this.addTextLine.dispatch(ChatMessage.make(Parameters.SERVER_CHAT_NAME, _local_2, -1, -1, "", false, _local_3));
				if (Parameters.autoDrink && _arg_1.code_ == 0)
				{
					Parameters.watchInv = true;
				}
			}

			private function onTradeAccepted(_arg_1:TradeAccepted):void
			{
				gs_.hudView.tradeAccepted(_arg_1);
				if (Parameters.autoAcceptTrades || Parameters.receivingPots)
				{
					acceptTrade(_arg_1.myOffer_, _arg_1.yourOffer_);
				}
			}

			private function addObject(_arg_1:ObjectData):void
			{
				var _local_2:AbstractMap = gs_.map;
				var _local_3:GameObject = ObjectLibrary.getObjectFromType(_arg_1.objectType_);
				var _local_4:ObjectStatusData = _arg_1.status_;
				_local_3.setObjectId(_local_4.objectId_);
				_local_2.addObj(_local_3, _local_4.pos_.x_, _local_4.pos_.y_);
				if ((_local_3 is Player))
				{
					this.handleNewPlayer((_local_3 as Player), _local_2);
				}
				this.processObjectStatus(_local_4, 0, -1);

				if (_local_3.props_.isEnemy_)
				{
					if (((((!(_local_3.dead_)) && (!((_local_3.props_.isCube_) && (Parameters.data_.fameBlockCubes)))) && (!((!(_local_3.props_.isGod_)) && (Parameters.data_.fameBlockGodsOnly)))) && (!(_local_3.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.IGNORE_PROJECTILE_NOINVULN_BITMASK))))
					{
						_local_2.vulnEnemyDict_.push(_local_3);
					}
				}
				else
				{
					if (_local_3.props_.isPlayer_)
					{
						if (!_local_3.isPaused && !_local_3.isInvincible && !_local_3.isStasis && !_local_3.dead_)
						{
							_local_2.vulnPlayerDict_.push(_local_3);
						}
						if (_local_3.objectId_ == this.playerId_)
						{
							if (!Parameters.ssmode && this.gs_.map.isVault)
							{
								_local_3.x_ = 44.5;
								_local_3.y_ = 70.5000001;
							}
						}
					}
				}
				if (_local_3.props_.static_ && _local_3.props_.occupySquare_ && !_local_3.props_.noMiniMap_)
				{
					this.updateGameObjectTileSignal.dispatch(new UpdateGameObjectTileVO(_local_3.x_, _local_3.y_, _local_3));
				}
				switch (_local_3.objectType_)
				{
					case 1825:
						Parameters.timerActive = true;
						Parameters.phaseChangeAt = (getTimer() + (120 * 1000));
						Parameters.phaseName = "Wine Cellar";
						break;
					case 3368:
					case 32694:
					case 29003:
					case 29021:
					case 29039:
						player.questMob1 = _local_3;
						break;
					case 3366:
					case 32692:
					case 29341:
						player.questMob2 = _local_3;
						break;
					case 3367:
					case 32693:
					case 29342:
						player.questMob3 = _local_3;
						break;
					case 29466:
					case 29563:
					case 29564:
						player.questMob1 = null;
						player.questMob2 = null;
						player.questMob3 = null;
						break;
				}
			}

			private function handleNewPlayer(_arg_1:Player, _arg_2:AbstractMap):void
			{
				this.setPlayerSkinTemplate(_arg_1, 0);
				if (_arg_1.objectId_ == this.playerId_)
				{
					this.player = _arg_1;
					this.model.player = _arg_1;
					_arg_2.player_ = _arg_1;
					_arg_1.relMoveVec_ = new Point(0, 0);
					_arg_1.conMoveVec = new Point(0, 0);
					gs_.setFocus(_arg_1);
					this.setGameFocus.dispatch(this.playerId_.toString());
				}
			}

			private function onUpdate(_arg_1:Update):void
			{
				var _local_3:int;
				var _local_4:GroundTileData;
				var _local_2:Message = this.messages.require(UPDATEACK);
				serverConnection.sendMessage(_local_2);
				_local_3 = 0;
				while (_local_3 < _arg_1.tiles_.length)
				{
					_local_4 = _arg_1.tiles_[_local_3];
					gs_.map.setGroundTile(_local_4.x_, _local_4.y_, _local_4.type_);
					this.updateGroundTileSignal.dispatch(new UpdateGroundTileVO(_local_4.x_, _local_4.y_, _local_4.type_));
					_local_3++;
				}
				_local_3 = 0;
				while (_local_3 < _arg_1.newObjs_.length)
				{
					this.addObject(_arg_1.newObjs_[_local_3]);
					_local_3++;
				}
				_local_3 = 0;
				while (_local_3 < _arg_1.drops_.length)
				{
					gs_.map.removeObj(_arg_1.drops_[_local_3]);
					_local_3++;
				}
				gs_.map.calcVulnerables();
			}

			private function onNotification(_arg_1:Notification):void
			{
				var _local_3:LineBuilder;
				var _local_2:GameObject = gs_.map.goDict_[_arg_1.objectId_];
				if (_local_2 != null)
				{
					_local_3 = LineBuilder.fromJSON(_arg_1.message);
					if (!Parameters.ssmode && Parameters.data_.ignoreStatusText)
					{
						if (_local_3.key == "server.no_effect")
						{
							return;
						}
					}
					if (_local_2 == this.player)
					{
						if (_local_3.key == "server.quest_complete")
						{
							gs_.map.quest_.completed();
						}
						if (_local_3.key == "server.plus_symbol" && _arg_1.color_ == 0xFF00)
						{
							this.player.addHealth(_local_3.tokens.amount);
						}
						this.makeNotification(_local_3, _local_2, _arg_1.color_, 1000);
					}
					else
					{
						if (_local_2.props_.isEnemy_ || !Parameters.data_.noAllyNotifications)
						{
							this.makeNotification(_local_3, _local_2, _arg_1.color_, 1000);
						}
					}
				}
			}

			private function makeNotification(_arg_1:LineBuilder, _arg_2:GameObject, _arg_3:uint, _arg_4:int):void
			{
				var _local_5:CharacterStatusText = new CharacterStatusText(_arg_2, _arg_3, _arg_4);
				_local_5.setStringBuilder(_arg_1);
				gs_.map.mapOverlay_.addStatusText(_local_5);
			}

			private function onGlobalNotification(_arg_1:GlobalNotification):void
			{
				switch (_arg_1.text)
				{
					case "yellow":
						ShowKeySignal.instance.dispatch(Key.YELLOW);
						return;
					case "red":
						ShowKeySignal.instance.dispatch(Key.RED);
						return;
					case "green":
						ShowKeySignal.instance.dispatch(Key.GREEN);
						return;
					case "purple":
						ShowKeySignal.instance.dispatch(Key.PURPLE);
						return;
					case "showKeyUI":
						ShowHideKeyUISignal.instance.dispatch();
						return;
					case "giftChestOccupied":
						this.giftChestUpdateSignal.dispatch(GiftStatusUpdateSignal.HAS_GIFT);
						return;
					case "giftChestEmpty":
						this.giftChestUpdateSignal.dispatch(GiftStatusUpdateSignal.HAS_NO_GIFT);
						return;
					case "beginnersPackage":
						return;
				}
			}

			private function onNewTick(_arg_1:NewTick):void
			{
				var _local_2:ObjectStatusData;
				if (jitterWatcher_ != null)
				{
					jitterWatcher_.record();
				}
				this.move(_arg_1.tickId_, this.player);
				for each (_local_2 in _arg_1.statuses_)
				{
					this.processObjectStatus(_local_2, _arg_1.tickTime_, _arg_1.tickId_);
				}
				lastTickId_ = _arg_1.tickId_;
				this.gs_.map.calcVulnerables();
				var _local_3:int = 0;
				var _local_4:Boolean;
				if (Parameters.usingPortal)
				{
					while (_local_3 < Parameters.portalSpamRate)
					{
						usePortal(Parameters.portalID);
						_local_3++;
					}
				}
				if (Parameters.watchInv)
				{
					_local_3 = 4;
					while (_local_3 < 12)
					{
						if (player.equipment_[_local_3] != -1)
						{
							if (player.shouldDrink(player.getPotType(player.equipment_[_local_3])))
							{
								useItem(gs_.lastUpdate_, player.objectId_, _local_3, player.equipment_[_local_3], player.x_, player.y_, 1);
								_local_4 = true;
							}
						}
						_local_3++;
					}
					if (_local_4)
					{
						Parameters.watchInv = false;
					}
				}
				if (Parameters.fameBot)
				{
					Parameters.famePointOffset = ((Parameters.data_.famePointOffset * Math.random()) - (Parameters.data_.famePointOffset * 0.5));
				}
			}

			private function canShowEffect(_arg_1:GameObject):Boolean
			{
				if (_arg_1 != null)
				{
					return (true);
				}
				var _local_2:Boolean = (_arg_1.objectId_ == this.playerId_);
				if (!_local_2 && _arg_1.props_.isPlayer_ && Parameters.data_.disableAllyShoot)
				{
					return (false);
				}
				return (true);
			}

			private function onShowEffect(_arg_1:ShowEffect):void
			{
				var _local_2:AbstractMap = gs_.map;
				var _local_3:GameObject;
				var _local_4:ParticleEffect;
				var _local_5:Point;
				var _local_6:uint;
				var object:GameObject = _local_2.goDict_[_arg_1.targetObjectId_];
				if (object != null)
				{
					if (object.objectType_ == 799 && _arg_1.color_ == 0xFF0000)
					{
						var _local_7:int = (object as Player).calcSealHeal();
						if (_local_7 != 0)
						{
							player.addSealHealth(_local_7);
						}
					}
					else
					{
						if (_arg_1.effectType_ == 12 && _arg_1.color_ == 0xFF0088)
						{
							Parameters.mystics.push(object.name_ + " " + getTimer());
						}
					}
					if (!Parameters.ssmode)
					{
						if (object.props_.isPlayer_ && object.objectId_ != this.playerId_ && Parameters.data_.alphaOnOthers)
						{
							return;
						}
					}
				}
				if (!Parameters.ssmode)
				{
					if (Parameters.lowCPUMode)
					{
						return;
					}
					if (Parameters.data_.liteParticle)
					{
						if (!(_arg_1.effectType_ == 4 || _arg_1.effectType_ == 12 || _arg_1.effectType_ == 16 || _arg_1.effectType_ == 15))
						{
							return;
						}
					}
				}
				if (Parameters.data_.noParticlesMaster && (_arg_1.effectType_ == ShowEffect.HEAL_EFFECT_TYPE || _arg_1.effectType_ == ShowEffect.TELEPORT_EFFECT_TYPE || _arg_1.effectType_ == ShowEffect.STREAM_EFFECT_TYPE || _arg_1.effectType_ == ShowEffect.POISON_EFFECT_TYPE || _arg_1.effectType_ == ShowEffect.LINE_EFFECT_TYPE || _arg_1.effectType_ == ShowEffect.FLOW_EFFECT_TYPE || _arg_1.effectType_ == ShowEffect.COLLAPSE_EFFECT_TYPE || _arg_1.effectType_ == ShowEffect.CONEBLAST_EFFECT_TYPE || _arg_1.effectType_ == ShowEffect.NOVA_NO_AOE_EFFECT_TYPE))
				{
					return;
				}
				switch (_arg_1.effectType_)
				{
					case ShowEffect.HEAL_EFFECT_TYPE:
						_local_3 = _local_2.goDict_[_arg_1.targetObjectId_];
						if (_local_3 == null || !this.canShowEffect(_local_3))
						{
							break;
						}
						_local_2.addObj(new HealEffect(_local_3, _arg_1.color_), _local_3.x_, _local_3.y_);
						return;
					case ShowEffect.TELEPORT_EFFECT_TYPE:
						_local_2.addObj(new TeleportEffect(), _arg_1.pos1_.x_, _arg_1.pos1_.y_);
						return;
					case ShowEffect.STREAM_EFFECT_TYPE:
						_local_4 = new StreamEffect(_arg_1.pos1_, _arg_1.pos2_, _arg_1.color_);
						_local_2.addObj(_local_4, _arg_1.pos1_.x_, _arg_1.pos1_.y_);
						return;
					case ShowEffect.THROW_EFFECT_TYPE:
						_local_3 = _local_2.goDict_[_arg_1.targetObjectId_];
						_local_5 = ((_local_3 != null) ? new Point(_local_3.x_, _local_3.y_) : _arg_1.pos2_.toPoint());
						if (_local_3 != null && !this.canShowEffect(_local_3))
						{
							break;
						}
						_local_4 = new ThrowEffect(_local_5, _arg_1.pos1_.toPoint(), _arg_1.color_, (_arg_1.duration_ * 1000));
						_local_2.addObj(_local_4, _local_5.x, _local_5.y);
						return;
					case ShowEffect.NOVA_EFFECT_TYPE:
					case ShowEffect.NOVA_NO_AOE_EFFECT_TYPE:
						_local_3 = _local_2.goDict_[_arg_1.targetObjectId_];
						if (_local_3 == null || !this.canShowEffect(_local_3))
						{
							break;
						}
						_local_4 = new NovaEffect(_local_3, _arg_1.pos1_.x_, _arg_1.color_);
						_local_2.addObj(_local_4, _local_3.x_, _local_3.y_);
						return;
					case ShowEffect.POISON_EFFECT_TYPE:
						_local_3 = _local_2.goDict_[_arg_1.targetObjectId_];
						if (_local_3 == null || !this.canShowEffect(_local_3))
						{
							break;
						}
						_local_4 = new PoisonEffect(_local_3, _arg_1.color_);
						_local_2.addObj(_local_4, _local_3.x_, _local_3.y_);
						return;
					case ShowEffect.LINE_EFFECT_TYPE:
						_local_3 = _local_2.goDict_[_arg_1.targetObjectId_];
						if (_local_3 == null || !this.canShowEffect(_local_3))
						{
							break;
						}
						_local_4 = new LineEffect(_local_3, _arg_1.pos1_, _arg_1.color_);
						_local_2.addObj(_local_4, _arg_1.pos1_.x_, _arg_1.pos1_.y_);
						return;
					case ShowEffect.BURST_EFFECT_TYPE:
						_local_3 = _local_2.goDict_[_arg_1.targetObjectId_];
						if (_local_3 == null || !this.canShowEffect(_local_3))
						{
							break;
						}
						_local_4 = new BurstEffect(_local_3, _arg_1.pos1_, _arg_1.pos2_, _arg_1.color_);
						_local_2.addObj(_local_4, _arg_1.pos1_.x_, _arg_1.pos1_.y_);
						return;
					case ShowEffect.FLOW_EFFECT_TYPE:
						_local_3 = _local_2.goDict_[_arg_1.targetObjectId_];
						if (_local_3 == null || !this.canShowEffect(_local_3))
						{
							break;
						}
						_local_4 = new FlowEffect(_arg_1.pos1_, _local_3, _arg_1.color_);
						_local_2.addObj(_local_4, _arg_1.pos1_.x_, _arg_1.pos1_.y_);
						return;
					case ShowEffect.RING_EFFECT_TYPE:
						_local_3 = _local_2.goDict_[_arg_1.targetObjectId_];
						if (_local_3 == null || !this.canShowEffect(_local_3))
						{
							break;
						}
						_local_4 = new RingEffect(_local_3, _arg_1.pos1_.x_, _arg_1.color_);
						_local_2.addObj(_local_4, _local_3.x_, _local_3.y_);
						return;
					case ShowEffect.LIGHTNING_EFFECT_TYPE:
						_local_3 = _local_2.goDict_[_arg_1.targetObjectId_];
						if (_local_3 == null || !this.canShowEffect(_local_3))
						{
							break;
						}
						_local_4 = new LightningEffect(_local_3, _arg_1.pos1_, _arg_1.color_, _arg_1.pos2_.x_);
						_local_2.addObj(_local_4, _local_3.x_, _local_3.y_);
						return;
					case ShowEffect.COLLAPSE_EFFECT_TYPE:
						_local_3 = _local_2.goDict_[_arg_1.targetObjectId_];
						if (_local_3 == null || !this.canShowEffect(_local_3))
						{
							break;
						}
						_local_4 = new CollapseEffect(_local_3, _arg_1.pos1_, _arg_1.pos2_, _arg_1.color_);
						_local_2.addObj(_local_4, _arg_1.pos1_.x_, _arg_1.pos1_.y_);
						return;
					case ShowEffect.CONEBLAST_EFFECT_TYPE:
						_local_3 = _local_2.goDict_[_arg_1.targetObjectId_];
						if (_local_3 == null || !this.canShowEffect(_local_3))
						{
							break;
						}
						_local_4 = new ConeBlastEffect(_local_3, _arg_1.pos1_, _arg_1.pos2_.x_, _arg_1.color_);
						_local_2.addObj(_local_4, _local_3.x_, _local_3.y_);
						return;
					case ShowEffect.JITTER_EFFECT_TYPE:
						gs_.camera_.startJitter();
						return;
					case ShowEffect.FLASH_EFFECT_TYPE:
						_local_3 = _local_2.goDict_[_arg_1.targetObjectId_];
						if (_local_3 == null || !this.canShowEffect(_local_3))
						{
							break;
						}
						_local_3.flash_ = new FlashDescription(getTimer(), _arg_1.color_, _arg_1.pos1_.x_, _arg_1.pos1_.y_);
						return;
					case ShowEffect.THROW_PROJECTILE_EFFECT_TYPE:
						_local_5 = _arg_1.pos1_.toPoint();
						if (_local_3 != null && !this.canShowEffect(_local_3))
						{
							break;
						}
						_local_4 = new ThrowProjectileEffect(_arg_1.color_, _arg_1.pos2_.toPoint(), _arg_1.pos1_.toPoint(), (_arg_1.duration_ * 1000));
						_local_2.addObj(_local_4, _local_5.x, _local_5.y);
						return;
					case ShowEffect.SHOCKER_EFFECT_TYPE:
						_local_3 = _local_2.goDict_[_arg_1.targetObjectId_];
						if (_local_3 == null || !this.canShowEffect(_local_3))
						{
							break;
						}
						if (_local_3 && _local_3.shockEffect)
						{
							_local_3.shockEffect.destroy();
						}
						_local_4 = new ShockerEffect(_local_3);
						_local_3.shockEffect = ShockerEffect(_local_4);
						gs_.map.addObj(_local_4, _local_3.x_, _local_3.y_);
						return;
					case ShowEffect.SHOCKEE_EFFECT_TYPE:
						_local_3 = _local_2.goDict_[_arg_1.targetObjectId_];
						if (_local_3 == null || !this.canShowEffect(_local_3))
						{
							break;
						}
						if (!_local_3.hasShock)
						{
							_local_4 = new ShockeeEffect(_local_3);
							gs_.map.addObj(_local_4, _local_3.x_, _local_3.y_);
						}
						return;
					case ShowEffect.RISING_FURY_EFFECT_TYPE:
						_local_3 = _local_2.goDict_[_arg_1.targetObjectId_];
						if (_local_3 == null || !this.canShowEffect(_local_3))
						{
							break;
						}
						_local_6 = (_arg_1.pos1_.x_ * 1000);
						_local_4 = new RisingFuryEffect(_local_3, _local_6);
						gs_.map.addObj(_local_4, _local_3.x_, _local_3.y_);
						return;
				}
			}

			private function onGoto(_arg_1:Goto):void
			{
				this.gotoAck(gs_.lastUpdate_);
				var _local_2:GameObject = gs_.map.goDict_[_arg_1.objectId_];
				if (_local_2 == null)
				{
					return;
				}
				_local_2.onGoto(_arg_1.pos_.x_, _arg_1.pos_.y_, gs_.lastUpdate_);
			}

			private function updateGameObject(_arg_1:GameObject, _arg_2:Vector.<StatData>, _arg_3:Boolean, _arg_4:Boolean):void
			{
				var _local_7:StatData;
				var _local_8:int;
				var _local_9:int;
				var _local_10:int;
				var _local_4:Player = (_arg_1 as Player);
				var _local_5:Merchant = (_arg_1 as Merchant);
				var _local_6:Pet = (_arg_1 as Pet);
				var _local_12:Boolean; // Change this
				if (_local_6)
				{
					this.petUpdater.updatePet(_local_6, _arg_2);
					if (gs_.map.isPetYard)
					{
						this.petUpdater.updatePetVOs(_local_6, _arg_2);
					}
					_arg_1.updateStatuses();
					return;
				}
				for each (_local_7 in _arg_2)
				{
					_local_8 = _local_7.statValue_;
					switch (_local_7.statType_)
					{
						case StatData.MAX_HP_STAT:
							if (_arg_3)
							{
								_local_4.maxHpChanged(_local_8);
								_arg_1.maxHP_ = _local_8;
								_local_4.calcHealthPercent();
							}
							else
							{
								_arg_1.maxHP_ = _local_8;
							}
							break;
						case StatData.HP_STAT:
							if (_arg_3)
							{
								if (_arg_4)
								{
									_local_4.clientHp = _local_8;
									_local_4.maxHpChanged(_local_8);
								}
								_local_4.hp2 = _local_8;
							}
							_arg_1.hp_ = _local_8;
							if (_arg_1.dead_ && _local_8 > 1 && _arg_1.props_.isEnemy_ && ++_arg_1.deadCounter_ >= 2)
							{
								_arg_1.dead_ = false;
							}
							break;
						case StatData.SIZE_STAT:
							_arg_1.size_ = _local_8;
							if (_arg_1 == player && Parameters.data_.nsetSkin[0] == "playerskins16")
							{
								_arg_1.size_ = 70;
							}
							break;
						case StatData.MAX_MP_STAT:
							_local_4.maxMP_ = _local_8;
							break;
						case StatData.MP_STAT:
							_local_4.mp_ = _local_8;
							break;
						case StatData.NEXT_LEVEL_EXP_STAT:
							_local_4.nextLevelExp_ = _local_8;
							break;
						case StatData.EXP_STAT:
							_local_4.exp_ = _local_8;
							break;
						case StatData.LEVEL_STAT:
							_arg_1.level_ = _local_8;
							break;
						case StatData.ATTACK_STAT:
							_local_4.attack_ = _local_8;
							break;
						case StatData.DEFENSE_STAT:
							_arg_1.defense_ = _local_8;
							break;
						case StatData.SPEED_STAT:
							_local_4.speed_ = _local_8;
							break;
						case StatData.DEXTERITY_STAT:
							_local_4.dexterity_ = _local_8;
							break;
						case StatData.VITALITY_STAT:
							_local_4.vitality_ = _local_8;
							break;
						case StatData.WISDOM_STAT:
							_local_4.wisdom_ = _local_8;
							break;
						case StatData.CONDITION_STAT:
							_arg_1.condition_[ConditionEffect.CE_FIRST_BATCH] = _local_8;
							_arg_1.updateStatuses();
							break;
						case StatData.INVENTORY_0_STAT:
						case StatData.INVENTORY_1_STAT:
						case StatData.INVENTORY_2_STAT:
						case StatData.INVENTORY_3_STAT:
						case StatData.INVENTORY_4_STAT:
						case StatData.INVENTORY_5_STAT:
						case StatData.INVENTORY_6_STAT:
						case StatData.INVENTORY_7_STAT:
						case StatData.INVENTORY_8_STAT:
						case StatData.INVENTORY_9_STAT:
						case StatData.INVENTORY_10_STAT:
						case StatData.INVENTORY_11_STAT:
							_local_9 = (_local_7.statType_ - StatData.INVENTORY_0_STAT);
							if (_local_8 != -1)
							{
								_arg_1.lockedSlot[_local_9] = 0;
							}
							_arg_1.equipment_[_local_9] = _local_8;
							break;
						case StatData.NUM_STARS_STAT:
							_local_4.numStars_ = _local_8;
							break;
						case StatData.NAME_STAT:
							if (_arg_1.name_ != _local_7.strStatValue_)
							{
								_arg_1.name_ = _local_7.strStatValue_;
								_arg_1.nameBitmapData_ = null;
								if (_arg_1.name_ == Parameters.followName)
								{
									Parameters.followPlayer = _arg_1;
								}
							}
							break;
						case StatData.TEX1_STAT:
							if (_local_4 == player)
							{
								Parameters.PlayerTex1 = _local_8;
							}
							if (!Parameters.data_.showDyes && !Parameters.ssmode && _local_4 != player || _local_8 <= 0)
							{
								_arg_1.setTex1(0);
							}
							else
							{
								_arg_1.setTex1(_local_8);
							}
							if (!Parameters.ssmode && _local_4 == player && Parameters.data_.setTex1 != -1)
							{
								_arg_1.setTex1(Parameters.data_.setTex1);
							}
							break;
						case StatData.TEX2_STAT:
							if (_local_4 == player)
							{
								Parameters.PlayerTex2 = _local_8;
							}
							if (!Parameters.data_.showDyes && !Parameters.ssmode && _local_4 != player || _local_8 <= 0)
							{
								_arg_1.setTex2(0);
							}
							else
							{
								_arg_1.setTex2(_local_8);
							}
							if (!Parameters.ssmode && _local_4 == player && Parameters.data_.setTex2 != -1)
							{
								_arg_1.setTex1(Parameters.data_.setTex2);
							}
							break;
						case StatData.MERCHANDISE_TYPE_STAT:
							_local_5.setMerchandiseType(_local_8);
							break;
						case StatData.CREDITS_STAT:
							_local_4.setCredits(_local_8);
							break;
						case StatData.MERCHANDISE_PRICE_STAT:
							(_arg_1 as SellableObject).setPrice(_local_8);
							break;
						case StatData.ACTIVE_STAT:
							(_arg_1 as Portal).active_ = _local_8 != 0;
							if (Parameters.fameBot && Parameters.fameBotPortalId == _arg_1.objectId_ && (PointUtil.distanceSquaredXY(this.player.x_, this.player.y_, _arg_1.x_, _arg_1.y_) <= 1))
							{
								if (_local_8 != 0)
								{
									usePortal(_arg_1.objectId_);
								}
							}
							break;
						case StatData.ACCOUNT_ID_STAT:
							_local_4.accountId_ = _local_7.strStatValue_;
							break;
						case StatData.FAME_STAT:
							_local_4.setFame(_local_8);
							break;
						case StatData.FORTUNE_TOKEN_STAT:
							_local_4.setTokens(_local_8);
							break;
						case StatData.MERCHANDISE_CURRENCY_STAT:
							(_arg_1 as SellableObject).setCurrency(_local_8);
							break;
						case StatData.CONNECT_STAT:
							_arg_1.connectType_ = _local_8;
							break;
						case StatData.MERCHANDISE_COUNT_STAT:
							_local_5.count_ = _local_8;
							_local_5.untilNextMessage_ = 0;
							break;
						case StatData.MERCHANDISE_MINS_LEFT_STAT:
							_local_5.minsLeft_ = _local_8;
							_local_5.untilNextMessage_ = 0;
							break;
						case StatData.MERCHANDISE_DISCOUNT_STAT:
							_local_5.discount_ = _local_8;
							_local_5.untilNextMessage_ = 0;
							break;
						case StatData.MERCHANDISE_RANK_REQ_STAT:
							(_arg_1 as SellableObject).setRankReq(_local_8);
							break;
						case StatData.MAX_HP_BOOST_STAT:
							if (_arg_3)
							{
								_local_12 = true;
							}
							_local_4.maxHPBoost_ = _local_8;
							break;
						case StatData.MAX_MP_BOOST_STAT:
							_local_4.maxMPBoost_ = _local_8;
							break;
						case StatData.ATTACK_BOOST_STAT:
							_local_4.attackBoost_ = _local_8;
							break;
						case StatData.DEFENSE_BOOST_STAT:
							_local_4.defenseBoost_ = _local_8;
							break;
						case StatData.SPEED_BOOST_STAT:
							_local_4.speedBoost_ = _local_8;
							break;
						case StatData.VITALITY_BOOST_STAT:
							_local_4.vitalityBoost_ = _local_8;
							break;
						case StatData.WISDOM_BOOST_STAT:
							_local_4.wisdomBoost_ = _local_8;
							break;
						case StatData.DEXTERITY_BOOST_STAT:
							_local_4.dexterityBoost_ = _local_8;
							break;
						case StatData.OWNER_ACCOUNT_ID_STAT:
							(_arg_1 as Container).setOwnerId(_local_7.strStatValue_);
							break;
						case StatData.RANK_REQUIRED_STAT:
							(_arg_1 as NameChanger).setRankRequired(_local_8);
							break;
						case StatData.NAME_CHOSEN_STAT:
							_local_4.nameChosen_ = _local_8 != 0;
							_arg_1.nameBitmapData_ = null;
							break;
						case StatData.CURR_FAME_STAT:
							_local_4.currFame_ = _local_8;
							break;
						case StatData.NEXT_CLASS_QUEST_FAME_STAT:
							_local_4.nextClassQuestFame_ = _local_8;
							break;
						case StatData.LEGENDARY_RANK_STAT:
							_local_4.legendaryRank_ = _local_8;
							break;
						case StatData.SINK_LEVEL_STAT:
							if (!_arg_3)
							{
								_local_4.sinkLevel_ = _local_8;
							}
							break;
						case StatData.ALT_TEXTURE_STAT:
							_arg_1.setAltTexture(_local_8);
							break;
						case StatData.GUILD_NAME_STAT:
							_local_4.setGuildName(_local_7.strStatValue_);
							break;
						case StatData.GUILD_RANK_STAT:
							_local_4.guildRank_ = _local_8;
							break;
						case StatData.BREATH_STAT:
							_local_4.breath_ = _local_8;
							break;
						case StatData.XP_BOOSTED_STAT:
							_local_4.xpBoost_ = _local_8;
							break;
						case StatData.XP_TIMER_STAT:
							_local_4.xpTimer = (_local_8 * TO_MILLISECONDS);
							break;
						case StatData.LD_TIMER_STAT:
							_local_4.dropBoost = (_local_8 * TO_MILLISECONDS);
							break;
						case StatData.LT_TIMER_STAT:
							_local_4.tierBoost = (_local_8 * TO_MILLISECONDS);
							break;
						case StatData.HEALTH_POTION_STACK_STAT:
							_local_4.healthPotionCount_ = _local_8;
							break;
						case StatData.MAGIC_POTION_STACK_STAT:
							_local_4.magicPotionCount_ = _local_8;
							break;
						case StatData.TEXTURE_STAT:
							if (_local_4 != null)
							{
								if (_local_4 == player)
								{
									Parameters.playerSkin = _local_8;
								}
								if (!Parameters.data_.showSkins && _local_4 != player)
								{
									break;
								}
								(_local_4.skinId != _local_8 && _local_8 >= 0 && this.setPlayerSkinTemplate(_local_4, _local_8));
								if (_local_4 == player && Parameters.data_.nsetSkin[1] != -1 && !Parameters.ssmode)
								{
									player.skin = AnimatedChars.getAnimatedChar(Parameters.data_.nsetSkin[0], Parameters.data_.nsetSkin[1]);
								}
							}
							else
							{
								if (_arg_1.objectType_ == 1813 && _local_8 > 0)
								{
									_arg_1.setTexture(_local_8);
								}
							}
							break;
						case StatData.HASBACKPACK_STAT:
							(_arg_1 as Player).hasBackpack_ = Boolean(_local_8);
							if (_arg_3)
							{
								this.updateBackpackTab.dispatch(Boolean(_local_8));
							}
							break;
						case StatData.BACKPACK_0_STAT:
						case StatData.BACKPACK_1_STAT:
						case StatData.BACKPACK_2_STAT:
						case StatData.BACKPACK_3_STAT:
						case StatData.BACKPACK_4_STAT:
						case StatData.BACKPACK_5_STAT:
						case StatData.BACKPACK_6_STAT:
						case StatData.BACKPACK_7_STAT:
							_local_10 = _local_7.statType_ - StatData.BACKPACK_0_STAT + GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS;
							(_arg_1 as Player).equipment_[_local_10] = _local_8;
							break;
						case StatData.NEW_CON_STAT:
							_arg_1.condition_[ConditionEffect.CE_SECOND_BATCH] = _local_8;
							_arg_1.updateStatuses();
							break;
					}
				}
				if (_arg_3)
				{
					if (_local_12)
					{
						_local_4.triggerHealBuffer();
					}
					if (Parameters.data_.AutoSyncClientHP && (Math.abs((_local_4.clientHp - _local_4.hp_)) > 60))
					{
						if (_local_4.ticksHPLastOff++ > 3)
						{
							_local_4.ticksHPLastOff = 0;
							_local_4.clientHp = _local_4.hp_;
						}
					}
				}
			}

			override public function setPlayerSkinTemplate(_arg_1:Player, _arg_2:int):void
			{
				var _local_3:Reskin = (this.messages.require(RESKIN) as Reskin);
				_local_3.skinID = _arg_2;
				_local_3.player = _arg_1;
				_local_3.consume();
			}

			private function processObjectStatus(_arg_1:ObjectStatusData, _arg_2:int, _arg_3:int):void
			{
				var _local_8:int;
				var _local_9:int;
				var _local_10:int;
				var _local_11:int;
				var _local_12:CharacterClass;
				var _local_13:XML;
				var _local_14:String;
				var _local_15:String;
				var _local_16:int;
				var _local_17:ObjectProperties;
				var _local_18:ProjectileProperties;
				var _local_19:Array;
				var _local_4:AbstractMap = gs_.map;
				var _local_5:GameObject = _local_4.goDict_[_arg_1.objectId_];
				if (_local_5 == null)
				{
					return;
				}
				var _local_6:Boolean = (_arg_1.objectId_ == this.playerId_);
				if (_arg_2 != 0)
				{
					if (!_local_6)
					{
						_local_5.onTickPos(_arg_1.pos_.x_, _arg_1.pos_.y_, _arg_2, _arg_3);
					}
					else
					{
						_local_5.tickPosition_.x = _arg_1.pos_.x_;
						_local_5.tickPosition_.y = _arg_1.pos_.y_;
					}
				}
				var _local_7:Player = (_local_5 as Player);
				if (_local_7 != null)
				{
					_local_8 = _local_7.level_;
					_local_9 = _local_7.exp_;
					_local_10 = _local_7.skinId;
					_local_11 = _local_7.currFame_;
				}
				this.updateGameObject(_local_5, _arg_1.stats_, _local_6, _arg_2 == 0);
				if (_local_7)
				{
					if (_local_6)
					{
						_local_12 = this.classesModel.getCharacterClass(_local_7.objectType_);
						if (_local_12.getMaxLevelAchieved() < _local_7.level_)
						{
							_local_12.setMaxLevelAchieved(_local_7.level_);
						}
					}
					if (_local_7.skinId != _local_10)
					{
						if (ObjectLibrary.skinSetXMLDataLibrary_[_local_7.skinId] != null)
						{
							_local_13 = (ObjectLibrary.skinSetXMLDataLibrary_[_local_7.skinId] as XML);
							_local_14 = _local_13.attribute("color");
							_local_15 = _local_13.attribute("bulletType");
							if (_local_8 != -1 && _local_14.length > 0)
							{
								_local_7.levelUpParticleEffect(parseInt(_local_14));
							}
							if (_local_15.length > 0)
							{
								_local_7.projectileIdSetOverrideNew = _local_15;
								_local_16 = _local_7.equipment_[0];
								_local_17 = ObjectLibrary.propsLibrary_[_local_16];
								_local_18 = _local_17.projectiles_[0];
								_local_7.projectileIdSetOverrideOld = _local_18.objectId_;
							}
						}
						else
						{
							if (ObjectLibrary.skinSetXMLDataLibrary_[_local_7.skinId] == null)
							{
								_local_7.projectileIdSetOverrideNew = "";
								_local_7.projectileIdSetOverrideOld = "";
							}
						}
					}
					if (_local_8 != -1 && _local_7.level_ > _local_8)
					{
						if (_local_6)
						{
							_local_19 = gs_.model.getNewUnlocks(_local_7.objectType_, _local_7.level_);
							_local_7.handleLevelUp(_local_19.length != 0);
							if (_local_19.length > 0)
							{
								this.newClassUnlockSignal.dispatch(_local_19);
							}
						}
						else
						{
							if (!Parameters.data_.noAllyNotifications)
							{
								_local_7.levelUpEffect(TextKey.PLAYER_LEVELUP);
							}
						}
					}
					else
					{
						if (_local_8 != -1 && _local_7.exp_ > _local_9)
						{
							if (_local_6 || !Parameters.data_.noAllyNotifications)
							{
								_local_7.handleExpUp((_local_7.exp_ - _local_9));
							}
						}
					}
					if (Parameters.data_.showFameGain && _local_11 != -1 && _local_7.currFame_ > _local_11)
					{
						if (_local_6)
						{
							_local_7.updateFame(_local_7.currFame_ - _local_11);
						}
					}
					if (_local_11 == -1 && _local_7.currFame_ > _local_11)
					{
						if (_local_6)
						{
							Parameters.fpmGain++;
							if (Parameters.data_.showFameGain)
							{
								_local_7.updateFame(_local_7.currFame_ - _local_11);
							}
						}
					}
					this.socialModel.updateFriendVO(_local_7.getName(), _local_7);
				}
			}

			private function onInvResult(_arg_1:InvResult):void
			{
				if (_arg_1.result_ != 0)
				{
					this.handleInvFailure();
				}
			}

			private function handleInvFailure():void
			{
				SoundEffectLibrary.play("error");
				gs_.hudView.interactPanel.redraw();
			}

			private function onReconnect(_arg_1:Reconnect):void
			{
				var _local_2:Server = new Server().setName(_arg_1.name_).setAddress(((_arg_1.host_ != "") ? _arg_1.host_ : server_.address)).setPort(((_arg_1.host_ != "") ? _arg_1.port_ : server_.port));
				var _local_3:int = _arg_1.gameId_;
				var _local_4:Boolean = createCharacter_;
				var _local_5:int = charId_;
				var _local_6:int = _arg_1.keyTime_;
				var _local_7:ByteArray = _arg_1.key_;
				isFromArena_ = _arg_1.isFromArena_;
				if (_arg_1.stats_)
				{
					this.statsTracker.setBinaryStringData(_local_5, _arg_1.stats_);
				}
				var _local_8:ReconnectEvent = new ReconnectEvent(_local_2, _local_3, _local_4, _local_5, _local_6, _local_7, isFromArena_);
				if (Parameters.fameBot && _arg_1.name_ == "Oryx's Castle")
				{
					if (Parameters.data_.fameOryx)
					{
						this.gs_.dispatchEvent(Parameters.reconNexus);
					}
					else
					{
						Parameters.fameBot = false;
					}
				}
				if (_local_8.server_.name.substr(0, 12) == "NexusPortal.")
				{
					if (Parameters.realmJoining)
					{
						if (_local_8.server_.name.substr(12).toLowerCase().indexOf(Parameters.realmName) == -1)
						{
							this.gs_.dispatchEvent(new ReconnectEvent(Parameters.reconNexus.server_, Parameters.RANDOM_REALM_GAMEID, false, this.charId_, -1, null, false));
							return;
						}
						Parameters.realmJoining = false;
					}
					Parameters.reconRealm = _local_8;
				}
				gs_.dispatchEvent(_local_8);
			}

			private function onPing(_arg_1:Ping):void
			{
				var _local_2:Pong = (this.messages.require(PONG) as Pong);
				_local_2.serial_ = _arg_1.serial_;
				_local_2.time_ = getTimer();
				serverConnection.sendMessage(_local_2);
				if (Parameters.fameBot)
				{
					Parameters.famePoint.x = (Parameters.famePointOffset * RandomUtil.randomRange(0.8, 1.2));
					Parameters.famePoint.y = (Parameters.famePointOffset * RandomUtil.randomRange(0.8, 1.2));
				}
				if (Parameters.data_.mapHack)
				{
					if (Parameters.needsMapCheck == 1)
					{
						if (this.gs_.hudView.miniMap.checkForMap(AssetLoader.realmMaps))
						{
							Parameters.needsMapCheck = 0;
						}
					}
					/*else
					{
						if (Parameters.needsMapCheck == 3)
						{
							if (this.gs_.hudView.miniMap.checkForMap(AssetLoader.nexusMaps))
							{
								Parameters.needsMapCheck = 0;
							}
						}
					}*/
				}
			}

			public static function parsePackets(_arg_1:XML = null):void
			{
				var _local_1:String;
				var _local_2:XML = (_arg_1 == null ? XML(new packets()) : _arg_1);
				var counter:int = 0;
				for (_local_1 in _local_2.Packet)
				{
					GameServerConnection[_local_2.Packet.PacketName[_local_1]] = parseInt(_local_2.Packet.PacketID[_local_1]);
					counter++;
				}
			}

			private function parseXML(_arg_1:String):void
			{
				var _local_2:XML = XML(_arg_1);
				GroundLibrary.parseFromXML(_local_2);
				ObjectLibrary.parseFromXML(_local_2);
			}

			private function setupReconnects(_arg_1:String):void
			{
				if (_arg_1 == "Nexus")
				{
					Parameters.reconNexus = new ReconnectEvent(new Server().setName("Nexus").setAddress(this.server_.address).setPort(this.server_.port), Parameters.NEXUS_GAMEID, false, this.charId_, 0, null, this.isFromArena_);
				}
				if (Parameters.reconNexus == null)
				{
					Parameters.reconNexus = new ReconnectEvent(new Server().setName("Nexus").setAddress(this.server_.address).setPort(this.server_.port), Parameters.NEXUS_GAMEID, false, this.charId_, 0, null, this.isFromArena_);
				}
				if (Parameters.reconVault == null)
				{
					Parameters.reconVault = new ReconnectEvent(new Server().setName("Vault").setAddress(this.server_.address).setPort(this.server_.port), Parameters.VAULT_GAMEID, false, this.charId_, 0, null, this.isFromArena_);
				}
				if (Parameters.reconTutor == null)
				{
					Parameters.reconTutor = new ReconnectEvent(new Server().setName("Tutorial").setAddress(this.server_.address).setPort(this.server_.port), Parameters.TUTORIAL_GAMEID, false, this.charId_, 0, null, this.isFromArena_);
				}
				if (Parameters.reconDaily == null)
				{
					Parameters.reconDaily = new ReconnectEvent(new Server().setName("Daily Quest Room").setAddress(this.server_.address).setPort(this.server_.port), Parameters.DAILYQUESTROOM_GAMEID, false, this.charId_, 0, null, this.isFromArena_);
				}
				if (Parameters.reconNexus)
				{
					Parameters.reconNexus.charId_ = this.charId_;
				}
				if (Parameters.reconVault)
				{
					Parameters.reconVault.charId_ = this.charId_;
				}
				if (Parameters.reconRealm)
				{
					Parameters.reconRealm.charId_ = this.charId_;
				}
				if (Parameters.reconDung)
				{
					Parameters.reconDung.charId_ = this.charId_;
				}
				if (Parameters.reconTutor)
				{
					Parameters.reconTutor.charId_ = this.charId_;
				}
				if (Parameters.reconDaily)
				{
					Parameters.reconDaily.charId_ = this.charId_;
				}
			}

			private function onMapInfo(_arg_1:MapInfo):void
			{
				var _local_2:String;
				var _local_3:String;
				Parameters.realmJoining = false;
				this.setupReconnects(_arg_1.name_);
				for each (_local_2 in _arg_1.clientXML_)
				{
					this.parseXML(_local_2);
				}
				for each (_local_3 in _arg_1.extraXML_)
				{
					this.parseXML(_local_3);
				}
				Map.teleportAllowed = _arg_1.allowPlayerTeleport_;
				changeMapSignal.dispatch();
				this.closeDialogs.dispatch();
				gs_.applyMapInfo(_arg_1);
				this.rand_ = new Random(_arg_1.fp_);
				if (Parameters.data_.famebotContinue == 0)
				{
					Parameters.fameBot = false;
				}
				if (Parameters.needToRecalcDesireables)
				{
					Parameters.setAutolootDesireables();
					Parameters.needToRecalcDesireables = false;
				}
				Parameters.fameWaitStartTime = 0;
				Parameters.fameWaitNTTime = 0;
				Parameters.fameWalkSleep_toFountainOrHall = 0;
				Parameters.fameWalkSleep_toRealms = 0;
				Parameters.fameWalkSleep2 = 0;
				Parameters.fameWalkSleepStart = 0;
				Parameters.questFollow = false;
				Parameters.VHS = 0;
				if (_arg_1.name_ == "Realm of the Mad God")
				{
					Parameters.mystics.length = 0;
				}
				if (Parameters.preload)
				{
					charId_ = Parameters.forceCharId;
					this.load();
				}
				else
				{
					if (createCharacter_)
					{
						this.create();
					}
					else
					{
						this.load();
					}
				}
				Parameters.ignoredShotCount = 0;
				Parameters.dmgCounter.length = 0;
				Parameters.needsMapCheck = gs_.map.needsMapHack(_arg_1.name_);
			}

			private function onPic(_arg_1:Pic):void
			{
				gs_.addChild(new PicView(_arg_1.bitmapData_));
			}

			private function onDeath(_arg_1:Death):void
			{
				this.death = _arg_1;
				var _local_2:BitmapData = new BitmapData(gs_.stage.stageWidth, gs_.stage.stageHeight);
				_local_2.draw(gs_);
				_arg_1.background = _local_2;
				if (!gs_.isEditor)
				{
					this.handleDeath.dispatch(_arg_1);
				}
				this.checkDavyKeyRemoval();
				Parameters.Cache_CHARLIST_valid = false;
				Parameters.fameBot = false;
			}

			private function onBuyResult(_arg_1:BuyResult):void
			{
				outstandingBuy_ = null;
				this.handleBuyResultType(_arg_1);
			}

			private function handleBuyResultType(_arg_1:BuyResult):void
			{
				var _local_2:ChatMessage;
				switch (_arg_1.result_)
				{
					case BuyResult.UNKNOWN_ERROR_BRID:
						_local_2 = ChatMessage.make(Parameters.SERVER_CHAT_NAME, _arg_1.resultString_);
						this.addTextLine.dispatch(_local_2);
						return;
					case BuyResult.NOT_ENOUGH_GOLD_BRID:
						this.openDialog.dispatch(new NotEnoughGoldDialog());
						return;
					case BuyResult.NOT_ENOUGH_FAME_BRID:
						this.openDialog.dispatch(new NotEnoughFameDialog());
						return;
					default:
						this.handleDefaultResult(_arg_1);
				}
			}

			private function handleDefaultResult(_arg_1:BuyResult):void
			{
				var _local_2:LineBuilder = LineBuilder.fromJSON(_arg_1.resultString_);
				var _local_3:Boolean = ((_arg_1.result_ == BuyResult.SUCCESS_BRID) || (_arg_1.result_ == BuyResult.PET_FEED_SUCCESS_BRID));
				var _local_4:ChatMessage = ChatMessage.make(((_local_3) ? Parameters.SERVER_CHAT_NAME : Parameters.ERROR_CHAT_NAME), _local_2.key);
				_local_4.tokens = _local_2.tokens;
				this.addTextLine.dispatch(_local_4);
			}

			private function onAccountList(_arg_1:AccountList):void
			{
				if (_arg_1.accountListId_ == 0)
				{
					if (_arg_1.lockAction_ != -1)
					{
						if (_arg_1.lockAction_ == 1)
						{
							gs_.map.party_.setStars(_arg_1);
						}
						else
						{
							gs_.map.party_.removeStars(_arg_1);
						}
					}
					else
					{
						gs_.map.party_.setStars(_arg_1);
					}
				}
				else
				{
					if (_arg_1.accountListId_ == 1)
					{
						gs_.map.party_.setIgnores(_arg_1);
					}
				}
			}

			private function onQuestObjId(_arg_1:QuestObjId):void
			{
				gs_.map.quest_.setObject(_arg_1.objectId_);
			}

			private function onAoe(_arg_1:Aoe):void
			{
				var _local_4:int;
				var _local_5:Vector.<uint>;
				if (this.player == null)
				{
					this.aoeAck(gs_.lastUpdate_, 0, 0);
					return;
				}
				var _local_2:AOEEffect = new AOEEffect(_arg_1.pos_.toPoint(), _arg_1.radius_, _arg_1.color_);
				gs_.map.addObj(_local_2, _arg_1.pos_.x_, _arg_1.pos_.y_);
				if (((this.player.isInvincible) || (this.player.isPaused)))
				{
					this.aoeAck(gs_.lastUpdate_, this.player.x_, this.player.y_);
					return;
				}
				var _local_3:Boolean = (this.player.distTo(_arg_1.pos_) < _arg_1.radius_);
				if (_local_3)
				{
					_local_4 = GameObject.damageWithDefense(_arg_1.damage_, this.player.defense_, false, this.player.condition_);
					_local_5 = null;
					if (_arg_1.effect_ != 0)
					{
						_local_5 = new Vector.<uint>();
						_local_5.push(_arg_1.effect_);
					}
					if (this.player.subtractDamage(_local_4))
					{
						return;
					}
					this.player.damage(true, _local_4, _local_5, false, null);
				}
				this.aoeAck(gs_.lastUpdate_, this.player.x_, this.player.y_);
			}

			private function onNameResult(_arg_1:NameResult):void
			{
				gs_.dispatchEvent(new NameResultEvent(_arg_1));
			}

			private function onGuildResult(_arg_1:GuildResult):void
			{
				var _local_2:LineBuilder;
				if (_arg_1.lineBuilderJSON == "")
				{
					gs_.dispatchEvent(new GuildResultEvent(_arg_1.success_, "", {}));
				}
				else
				{
					_local_2 = LineBuilder.fromJSON(_arg_1.lineBuilderJSON);
					this.addTextLine.dispatch(ChatMessage.make(Parameters.ERROR_CHAT_NAME, _local_2.key, -1, -1, "", false, _local_2.tokens));
					gs_.dispatchEvent(new GuildResultEvent(_arg_1.success_, _local_2.key, _local_2.tokens));
				}
			}

			private function onClientStat(_arg_1:ClientStat):void
			{
				var _local_2:Account = StaticInjectorContext.getInjector().getInstance(Account);
				if (!Parameters.ssmode && Parameters.data_.showClientStat)
				{
					if (!Parameters.usingPortal)
					{
						this.addTextLine.dispatch(ChatMessage.make(("#" + _arg_1.name_), _arg_1.value_.toString()));
						_local_2 = StaticInjectorContext.getInjector().getInstance(Account);
						_local_2.reportIntStat(_arg_1.name_, _arg_1.value_);
					}
				}
			}

			private function onFile(_arg_1:File):void
			{
				new FileReference().save(_arg_1.file_, _arg_1.filename_);
			}

			private function onInvitedToGuild(_arg_1:InvitedToGuild):void
			{
				if (Parameters.data_.showGuildInvitePopup)
				{
					gs_.hudView.interactPanel.setOverride(new GuildInvitePanel(gs_, _arg_1.name_, _arg_1.guildName_));
				}
				this.addTextLine.dispatch(ChatMessage.make("", ("You have been invited by " + _arg_1.name_ + " to join the guild " + _arg_1.guildName_ + '.\n  If you wish to join type "/join ' + _arg_1.guildName_ + '"')));
			}

			private function onPlaySound(_arg_1:PlaySound):void
			{
				var _local_2:GameObject = gs_.map.goDict_[_arg_1.ownerId_];
				((_local_2) && (_local_2.playSound(_arg_1.soundId_)));
			}

			private function onImminentArenaWave(_arg_1:ImminentArenaWave):void
			{
				this.imminentWave.dispatch(_arg_1.currentRuntime);
			}

			private function onArenaDeath(_arg_1:ArenaDeath):void
			{
				this.addTextLine.dispatch(ChatMessage.make("ArenaDeath", ("Cost: " + _arg_1.cost)));
				this.currentArenaRun.costOfContinue = _arg_1.cost;
				this.openDialog.dispatch(new ContinueOrQuitDialog(_arg_1.cost, false));
				this.arenaDeath.dispatch();
			}

			private function onVerifyEmail(_arg_1:VerifyEmail):void
			{
				TitleView.queueEmailConfirmation = true;
				if (gs_ != null)
				{
					gs_.closed.dispatch();
				}
				var _local_2:HideMapLoadingSignal = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
				if (_local_2 != null)
				{
					_local_2.dispatch();
				}
			}

			private function onPasswordPrompt(_arg_1:PasswordPrompt):void
			{
				if (_arg_1.cleanPasswordStatus == 3)
				{
					TitleView.queuePasswordPromptFull = true;
				}
				else
				{
					if (_arg_1.cleanPasswordStatus == 2)
					{
						TitleView.queuePasswordPrompt = true;
					}
					else
					{
						if (_arg_1.cleanPasswordStatus == 4)
						{
							TitleView.queueRegistrationPrompt = true;
						}
					}
				}
				if (gs_ != null)
				{
					gs_.closed.dispatch();
				}
				var _local_2:HideMapLoadingSignal = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
				if (_local_2 != null)
				{
					_local_2.dispatch();
				}
			}

			override public function questFetch():void
			{
				serverConnection.sendMessage(this.messages.require(QUESTFETCHASK));
			}

			private function onQuestFetchResponse(_arg_1:QuestFetchResponse):void
			{
				this.questFetchComplete.dispatch(_arg_1);
				if (Parameters.dailyCalendar2RunOnce)
				{
					this.gs_.showDailyLoginCalendar();
					Parameters.dailyCalendar2RunOnce = false;
					this.escape();
				}
			}

			private function onQuestRedeemResponse(_arg_1:QuestRedeemResponse):void
			{
				this.questRedeemComplete.dispatch(_arg_1);
			}

			override public function questRedeem(_arg_1:String, _arg_2:Vector.<SlotObjectData>, _arg_3:int = -1):void
			{
				var _local_4:QuestRedeem = (this.messages.require(QUESTREDEEM) as QuestRedeem);
				_local_4.questID = _arg_1;
				_local_4.item = _arg_3;
				_local_4.slots = _arg_2;
				serverConnection.sendMessage(_local_4);
			}

			override public function keyInfoRequest(_arg_1:int):void
			{
				var _local_2:KeyInfoRequest = (this.messages.require(KEYINFOREQUEST) as KeyInfoRequest);
				_local_2.itemType_ = _arg_1;
				serverConnection.sendMessage(_local_2);
			}

			private function onKeyInfoResponse(_arg_1:KeyInfoResponse):void
			{
				this.keyInfoResponse.dispatch(_arg_1);
			}

			private function onLoginRewardResponse(_arg_1:ClaimDailyRewardResponse):void
			{
				this.claimDailyRewardResponse.dispatch(_arg_1);
			}

			override public function petUpgradeRequest(_arg_1:int, _arg_2:int, _arg_3:int, _arg_4:int, _arg_5:int, _arg_6:int):void
			{
				var _local_7:PetUpgradeRequest = (this.messages.require(PETUPGRADEREQUEST) as PetUpgradeRequest);
				_local_7.objectId = _arg_5;
				_local_7.paymentTransType = _arg_1;
				_local_7.petTransType = _arg_2;
				_local_7.PIDOne = _arg_3;
				_local_7.PIDTwo = _arg_4;
				_local_7.slotsObject = new Vector.<SlotObjectData>();
				_local_7.slotsObject.push(new SlotObjectData());
				_local_7.slotsObject[0].objectId_ = this.playerId_;
				_local_7.slotsObject[0].slotId_ = _arg_6;
				if (this.player.equipment_.length >= _arg_6)
				{
					_local_7.slotsObject[0].objectType_ = this.player.equipment_[_arg_6];
				}
				else
				{
					_local_7.slotsObject[0].objectType_ = -1;
				}
				this.serverConnection.sendMessage(_local_7);
			}

			private function onClosed():void
			{
				var _local_2:HideMapLoadingSignal;
				if (this.playerId_ != -1)
				{
					this.logger.error("Closerino");
					gs_.closed.dispatch();
				}
				else
				{
					if (this.retryConnection_)
					{
						if (this.delayBeforeReconnect < 10)
						{
							if (this.delayBeforeReconnect == 6)
							{
								_local_2 = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
								_local_2.dispatch();
							}
							this.retry(this.delayBeforeReconnect++);
							this.addTextLine.dispatch(ChatMessage.make(Parameters.ERROR_CHAT_NAME, "Connection failed!  Retrying..."));
						}
						else
						{
							gs_.closed.dispatch();
						}
					}
				}
			}

			private function retry(_arg_1:int):void
			{
				this.retryTimer_ = new Timer((_arg_1 * 1000), 1);
				this.retryTimer_.addEventListener(TimerEvent.TIMER_COMPLETE, this.onRetryTimer);
				this.retryTimer_.start();
			}

			private function onRetryTimer(_arg_1:TimerEvent):void
			{
				serverConnection.connect(server_.address, server_.port);
			}

			private function onError(_arg_1:String):void
			{
				this.addTextLine.dispatch(ChatMessage.make(Parameters.ERROR_CHAT_NAME, _arg_1));
			}

			private function onFailure(_arg_1:Failure):void
			{
				if (LineBuilder.getLocalizedStringFromJSON(_arg_1.errorDescription_).hasOwnProperty("is dead") || _arg_1.errorDescription_.hasOwnProperty("is dead"))
				{
					Parameters.Cache_CHARLIST_valid = false;
				}
				if (Parameters.fameBot || _arg_1.errorDescription_.indexOf("server.realm_full") != -1)
				{
					return;
				}
				switch (_arg_1.errorId_)
				{
					case Failure.INCORRECT_VERSION:
						this.handleIncorrectVersionFailure(_arg_1);
						return;
					case Failure.BAD_KEY:
						this.handleBadKeyFailure(_arg_1);
						return;
					case Failure.INVALID_TELEPORT_TARGET:
						this.handleInvalidTeleportTarget(_arg_1);
						return;
					case Failure.EMAIL_VERIFICATION_NEEDED:
						this.handleEmailVerificationNeeded(_arg_1);
						return;
					case Failure.TELEPORT_REALM_BLOCK:
						this.handleRealmTeleportBlock(_arg_1);
						return;
					default:
						this.handleDefaultFailure(_arg_1);
				}
			}

			private function handleEmailVerificationNeeded(_arg_1:Failure):void
			{
				this.retryConnection_ = false;
				gs_.closed.dispatch();
			}

			private function handleRealmTeleportBlock(_arg_1:Failure):void
			{
				this.addTextLine.dispatch(ChatMessage.make(Parameters.SERVER_CHAT_NAME, ("You need to wait at least " + _arg_1.errorDescription_ + " seconds before a non guild member teleport.")));
				this.player.nextTeleportAt_ = (getTimer() + (int(_arg_1.errorDescription_) * 1000));
			}

			private function handleInvalidTeleportTarget(_arg_1:Failure):void
			{
				var _local_2:String = LineBuilder.getLocalizedStringFromJSON(_arg_1.errorDescription_);
				if (_local_2 == "")
				{
					_local_2 = _arg_1.errorDescription_;
				}
				this.addTextLine.dispatch(ChatMessage.make(Parameters.ERROR_CHAT_NAME, _local_2));
				this.player.nextTeleportAt_ = 0;
			}

			private function handleBadKeyFailure(_arg_1:Failure):void
			{
				var _local_2:String = LineBuilder.getLocalizedStringFromJSON(_arg_1.errorDescription_);
				if (_local_2 == "")
				{
					_local_2 = _arg_1.errorDescription_;
				}
				this.addTextLine.dispatch(ChatMessage.make(Parameters.ERROR_CHAT_NAME, _local_2));
				this.retryConnection_ = false;
				gs_.closed.dispatch();
			}

			private function handleIncorrectVersionFailure(_arg_1:Failure):void
			{
				Parameters.data_.gameVersion = _arg_1.errorDescription_;
				Parameters.save();
				var _local_2:Dialog = new Dialog(TextKey.CLIENT_UPDATE_TITLE, "", TextKey.CLIENT_UPDATE_LEFT_BUTTON, null);
				_local_2.setTextParams(TextKey.CLIENT_UPDATE_DESCRIPTION, {
					"client": Parameters.data_.gameVersion,
					"server": _arg_1.errorDescription_
				});
				_local_2.addEventListener(Dialog.LEFT_BUTTON, this.onDoClientUpdate);
				gs_.stage.addChild(_local_2);
				this.retryConnection_ = false;
			}

			private function handleDefaultFailure(_arg_1:Failure):void
			{
				var _local_2:String = LineBuilder.getLocalizedStringFromJSON(_arg_1.errorDescription_);
				if (_local_2 == "")
				{
					_local_2 = _arg_1.errorDescription_;
				}
				this.addTextLine.dispatch(ChatMessage.make(Parameters.ERROR_CHAT_NAME, _local_2));
				if (Parameters.fameBot)
				{
					if (_local_2.indexOf("Lost connection") != -1)
					{
						if (Parameters.reconRealm != null)
						{
							this.gs_.dispatchEvent(Parameters.reconRealm);
						}
					}
				}
			}

			private function onDoClientUpdate(_arg_1:Event):void
			{
				var _local_2:Dialog = (_arg_1.currentTarget as Dialog);
				_local_2.parent.removeChild(_local_2);
				gs_.closed.dispatch();
			}

			override public function isConnected():Boolean
			{
				return (serverConnection.isConnected());
			}

			override public function reskin(_arg_1:Player, _arg_2:int):void
			{
				var _local_3:Reskin = (this.messages.require(RESKIN) as Reskin);
				_local_3.skinID = _arg_2;
				_local_3.player = _arg_1;
				serverConnection.sendMessage(_local_3);
			}


		}
	}//package kabam.rotmg.messaging.impl

