import {Box} from '@chakra-ui/react'
import { useEffect, useState } from "react";
import PieceItem from "@render/pages/Pieces/PieceItem.tsx";


function Pieces() {
  const [list, setList] = useState([]);
  useEffect(() => {
    getApiPieces();
  }, []);
  const getApiPieces = async () => {
    const res = await fetch("http://localhost:3000/api/pieces")
    const json = await res.json();
    setList(json);
  };

  return (
    <Box p={4}>
      {list &&
        list.map((item) => (
          <PieceItem
            key={item.id}
            item={item}
          />
        ))
      }
    </Box>
  )
}

export default Pieces
