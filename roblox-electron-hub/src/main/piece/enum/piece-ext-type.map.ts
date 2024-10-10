import {PieceTypeEnum} from "@main/piece/enum/piece-type.enum.ts";

export const PieceExtTypeMap: Map<string, PieceTypeEnum> = new Map ([
  ['.png', PieceTypeEnum.image],
  ['.jpg', PieceTypeEnum.image],
  ['.jpeg', PieceTypeEnum.image],
  ['.jpeg', PieceTypeEnum.image],
  ['.gif', PieceTypeEnum.image],
  ['.obj', PieceTypeEnum.mesh],
])
