import { promptAction } from '@kit.ArkUI';

function applyOpacityToHexColor(hexColor: string, opacity: number): string {
  let normalizedOpacity: number;
  normalizedOpacity = Math.max(0, Math.min(1, opacity));

  const alphaDecimal: number = normalizedOpacity * 255;
  const alphaInteger: number = Math.round(alphaDecimal);

  let alphaHex: string = alphaInteger.toString(16);

  if (alphaHex.length < 2) {
    alphaHex = '0' + alphaHex;
  } else {
  }

  if (hexColor.startsWith('#')) {
    const rgbPart: string = hexColor.substring(1);
    const rgbPartLength: number = rgbPart.length;

    if (rgbPartLength === 6) {
      const resultColor: string = `#${alphaHex}${rgbPart}`;
      return resultColor;
    } else if (rgbPartLength === 3) {
      const rChar: string = rgbPart[0];
      const gChar: string = rgbPart[1];
      const bChar: string = rgbPart[2];

      const fullRgbPart: string = `${rChar}${rChar}${gChar}${gChar}${bChar}${bChar}`;
      const resultColor: string = `#${alphaHex}${fullRgbPart}`;
      return resultColor;
    } else {
      return hexColor;
    }
  } else {
    return hexColor;
  }
}

const APP_BACKGROUND_COLOR: ResourceColor = '#2C3E50';
const TEXT_COLOR_PRIMARY: ResourceColor = '#ECF0F1';
const TEXT_COLOR_SECONDARY: ResourceColor = '#BDC3C7';
const SCORE_TEXT_COLOR: ResourceColor = '#F1C40F';

const BULB_AREA_BACKGROUND: ResourceColor = '#34495E';
const BULB_OFF_COLOR: ResourceColor = '#7F8C8D';
const BULB_ON_COLOR_SYSTEM: ResourceColor = '#E67E22';
const BULB_ON_COLOR_USER_CHOICE: ResourceColor = '#2ECC71';
const BULB_ON_USER_WRONG_HINT_COLOR: ResourceColor = '#E74C3C';

const FONT_SIZE_SCORE: Length = 20;
const FONT_SIZE_MESSAGE: Length = 14;
const FONT_SIZE_BULB_LABEL: Length = 10;

const PADDING_MAIN_TOP: Length = 0;
const PADDING_MAIN_BOTTOM: Length = 0;
const PADDING_MAIN_LEFT: Length = 12;
const PADDING_MAIN_RIGHT: Length = 12;
const PADDING_GRID_ITEM_CONTAINER: number = 8;
const PADDING_GRID_ITEM_CONTENT: number = 6;
const MARGIN_TEXT_TOP: number = 0;
const MARGIN_MESSAGE_BOTTOM: Length = 0;

const BORDER_RADIUS_BULB_OUTER: Length = 10;
const BORDER_RADIUS_BULB_INNER: Length = 35;
const BORDER_RADIUS_CONTAINER: Length = 12;

const BULB_ITEM_SIZE: Length = 75;
const TOGGLE_WIDTH: Length = 40;
const TOGGLE_HEIGHT: Length = 24;

const SHADOW_COLOR_LIGHT: ResourceColor = '#33000000';
const SHADOW_COLOR_STRONG: ResourceColor = '#55000000';
const BULB_GLOW_OPACITY_FOR_SHADOW: number = 0.6;

const SCORE_SHADOW_RADIUS: number = 2;
const BULB_OFF_SHADOW_RADIUS: number = 3;
const BULB_OFF_SHADOW_OFFSET: number = 2;
const BULB_ON_SHADOW_RADIUS: number = 10;
const GRID_SHADOW_RADIUS: number = 5;
const GRID_SHADOW_OFFSET_Y: number = 3;


@Entry
@Component
struct LightBulbGame {
  @State bulbs: boolean[] = [false, false, false, false];
  @State userGuessedIndex: number | null = null;
  @State targetBulb: number = 0;
  @State score: number = 0;
  @State message: string = 'Tap screen to start!';
  @State isPlaying: boolean = false;
  @State isSystemFlashing: boolean = false;
  @State revealTargetOnWrong: boolean = false;

  resetVisualStates(): void {
    const newBulbsState: boolean[] = [false, false, false, false];
    this.bulbs = newBulbsState;
    this.userGuessedIndex = null;
    this.isSystemFlashing = false;
    this.revealTargetOnWrong = false;
  }

  startRound(): void {
    this.resetVisualStates();
    this.isPlaying = true;

    const numberOfBulbs: number = this.bulbs.length;
    const randomFloat: number = Math.random();
    const randomIndex: number = Math.floor(randomFloat * numberOfBulbs);
    this.targetBulb = randomIndex;

    this.message = 'Watch the light!';
    this.isSystemFlashing = true;

    const flashOnDelay: number = 1000;
    setTimeout(() => {
      const stillInFlashingPhase: boolean = this.isPlaying && this.isSystemFlashing && this.message === 'Watch the light!';
      if (!stillInFlashingPhase) {
        this.resetVisualStates();
        return;
      }

      const newBulbsAfterFlashOn: boolean[] = [...this.bulbs];
      newBulbsAfterFlashOn[this.targetBulb] = true;
      this.bulbs = newBulbsAfterFlashOn;

      const flashOffDelay: number = 1000;
      setTimeout(() => {
        const stillInFlashingPhaseForOff: boolean = this.isPlaying && this.isSystemFlashing && this.message === 'Watch the light!';
        if (!stillInFlashingPhaseForOff) {
          this.resetVisualStates();
          return;
        }

        const resetBulbsAfterFlashOff: boolean[] = [...this.bulbs];
        resetBulbsAfterFlashOff[this.targetBulb] = false;
        this.bulbs = resetBulbsAfterFlashOff;

        this.isSystemFlashing = false;
        this.message = 'Your turn!';
      }, flashOffDelay);
    }, flashOnDelay);
  }

  checkGuess(selectedIndex: number): void {
    const isGameReadyForGuess: boolean = this.isPlaying && (this.message === 'Your turn!');
    if (!isGameReadyForGuess) {
      return;
    }

    this.isPlaying = false;
    this.userGuessedIndex = selectedIndex;

    const bulbsToShowUserGuess: boolean[] = [false, false, false, false];
    bulbsToShowUserGuess[selectedIndex] = true;
    this.bulbs = bulbsToShowUserGuess;

    let wasGuessCorrect: boolean;
    if (selectedIndex === this.targetBulb) {
      wasGuessCorrect = true;
    } else {
      wasGuessCorrect = false;
    }

    if (wasGuessCorrect === true) {
      let currentScore: number = this.score;
      let newScore: number = currentScore + 1;
      this.score = newScore;

      const correctToastMessage: string = 'Correct! +1';
      const correctToastDuration: number = 1000;
      promptAction.showToast({ message: correctToastMessage, duration: correctToastDuration });

    } else {
      this.revealTargetOnWrong = true;

      const updatedBulbsForWrongGuess: boolean[] = [...this.bulbs];
      if (this.targetBulb !== selectedIndex) {
        updatedBulbsForWrongGuess[this.targetBulb] = true;
      }
      this.bulbs = updatedBulbsForWrongGuess;

      const wrongToastMessage: string = `Wrong! B${this.targetBulb + 1}`;
      const wrongToastDuration: number = 1500;
      promptAction.showToast({ message: wrongToastMessage, duration: wrongToastDuration });
    }

    let endOfRoundDelay: number;
    if (this.revealTargetOnWrong === true) {
      endOfRoundDelay = 1800;
    } else {
      endOfRoundDelay = 1500;
    }

    setTimeout(() => {
      this.resetVisualStates();
      this.message = 'Tap screen to start!';
      this.isPlaying = false;
    }, endOfRoundDelay);
  }

  determineBulbColor(index: number, isOn: boolean): ResourceColor {
    if (isOn === true) {
      const isTargetDuringSystemFlash: boolean = this.isSystemFlashing && (index === this.targetBulb);
      if (isTargetDuringSystemFlash === true) {
        return BULB_ON_COLOR_SYSTEM;
      }

      const hasUserGuessed: boolean = this.userGuessedIndex !== null;
      if (hasUserGuessed === true) {
        const isThisTheBulbUserGuessed: boolean = (index === this.userGuessedIndex);
        if (isThisTheBulbUserGuessed === true) {
          const wasUserGuessCorrectForThisBulb: boolean = (this.userGuessedIndex === this.targetBulb);
          if (wasUserGuessCorrectForThisBulb === true) {
            return BULB_ON_COLOR_USER_CHOICE;
          } else {
            return BULB_ON_USER_WRONG_HINT_COLOR;
          }
        }

        const shouldRevealThisAsTarget: boolean = this.revealTargetOnWrong &&
          (index === this.targetBulb) &&
          (index !== this.userGuessedIndex);
        if (shouldRevealThisAsTarget === true) {
          return BULB_ON_COLOR_SYSTEM;
        }
      }
      return BULB_ON_COLOR_SYSTEM;
    } else {
      return BULB_OFF_COLOR;
    }
  }

  build() {
    Column() {
      Text(`Score: ${this.score}`)
        .fontSize(FONT_SIZE_SCORE)
        .fontWeight(FontWeight.Bold)
        .fontColor(SCORE_TEXT_COLOR)
        .margin({
          top: MARGIN_TEXT_TOP,
          bottom: MARGIN_TEXT_TOP / 2
        })
        .shadow({
          radius: SCORE_SHADOW_RADIUS,
          color: SHADOW_COLOR_LIGHT,
          offsetX: 1,
          offsetY: 1
        });

      Text(this.message)
        .fontSize(FONT_SIZE_MESSAGE)
        .fontColor(TEXT_COLOR_SECONDARY)
        .margin({
          bottom: MARGIN_MESSAGE_BOTTOM
        })
        .textAlign(TextAlign.Center)
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        });

      Grid() {
        ForEach(
          this.bulbs,
          (isOn: boolean, index: number) => {
            GridItem() {
              Column() {
                Toggle({
                  type: ToggleType.Switch,
                  isOn: isOn
                })
                  .height(TOGGLE_HEIGHT)
                  .width(TOGGLE_WIDTH)
                  .selectedColor(this.determineBulbColor(index, true))
                  .switchPointColor(Color.White)
                  .enabled(this.message === 'Your turn!' && this.isPlaying)
                  .onChange((value: boolean) => {
                    const canUserInteractWithToggle: boolean = this.message === 'Your turn!' && this.isPlaying;
                    if (value === true && canUserInteractWithToggle) {
                      this.checkGuess(index);
                    } else if (value === false && this.bulbs[index] === true && canUserInteractWithToggle) {
                    }
                  })
                  .margin({ bottom: PADDING_GRID_ITEM_CONTENT / 2 })
                  .animation({ duration: 200, curve: Curve.EaseOut });

                Text(`B${index + 1}`)
                  .fontSize(FONT_SIZE_BULB_LABEL)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(TEXT_COLOR_PRIMARY);

              }
              .width(BULB_ITEM_SIZE)
              .height(BULB_ITEM_SIZE)
              .backgroundColor(this.determineBulbColor(index, isOn))
              .borderRadius(BORDER_RADIUS_BULB_INNER)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .padding(PADDING_GRID_ITEM_CONTENT)
              .border({
                width: 2,
                color: '#33000000',
                radius: BORDER_RADIUS_BULB_INNER
              })
              .shadow(
                isOn ?
                  {
                    radius: BULB_ON_SHADOW_RADIUS,
                    color: applyOpacityToHexColor(this.determineBulbColor(index, isOn) as string, BULB_GLOW_OPACITY_FOR_SHADOW),
                    offsetX: 0,
                    offsetY: 0
                  } :
                  {
                    radius: BULB_OFF_SHADOW_RADIUS,
                    color: SHADOW_COLOR_LIGHT,
                    offsetX: BULB_OFF_SHADOW_OFFSET,
                    offsetY: BULB_OFF_SHADOW_OFFSET
                  }
              )
              .animation({
                duration: 250,
                curve: Curve.EaseOut
              });

            }
            .padding(PADDING_GRID_ITEM_CONTAINER / 3)
            .borderRadius(BORDER_RADIUS_BULB_OUTER);
          }
        );

      }
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(PADDING_GRID_ITEM_CONTAINER / 2)
      .rowsGap(PADDING_GRID_ITEM_CONTAINER / 2)
      .width('90%')
      .aspectRatio(1)
      .padding(PADDING_GRID_ITEM_CONTAINER)
      .backgroundColor(BULB_AREA_BACKGROUND)
      .borderRadius(BORDER_RADIUS_CONTAINER)
      .shadow({
        radius: GRID_SHADOW_RADIUS,
        color: SHADOW_COLOR_STRONG,
        offsetX: 0,
        offsetY: GRID_SHADOW_OFFSET_Y
      });
    }
    .width('100%')
    .height('100%')
    .padding({top: PADDING_MAIN_TOP, bottom: PADDING_MAIN_BOTTOM, left: PADDING_MAIN_LEFT, right: PADDING_MAIN_RIGHT})
    .backgroundColor(APP_BACKGROUND_COLOR)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      const canStartGameOnClick: boolean = !this.isPlaying &&
        (this.message === 'Tap screen to start!' || this.message === 'Tap to start!');
      if (canStartGameOnClick === true) {
        this.startRound();
      } else {
      }
    });
  }
}