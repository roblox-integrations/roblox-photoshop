import {Image, Card, Stack, CardBody, Heading, CardFooter, Button, Text, Badge, Flex, Switch, FormLabel} from '@chakra-ui/react'
import {useState, useEffect} from "react";

export default function PieceItem({item}) {
  const [isAutoSave, setIsAutoSave] = useState(item.isAutoSave);

  function onReveal () {
    window.electron.reveal(item.filePath);
  }

  const updatePieceItem = async () => {
    console.log('[PieceItem] before', isAutoSave)

    const res = await fetch(`http://localhost:3000/api/pieces/${item.id}`, {
      method: 'PATCH',
      body: JSON.stringify({isAutoSave}),
      headers: {
        'Content-Type': 'application/json',
      }
    })
    const json = await res.json();
    console.log('[PieceItem] updated', json)
  };

  async function onChangeIsAuthSave () {
    setIsAutoSave(!isAutoSave)
    //console.log('[PieceItem] onChange', isAutoSave)
    //await updatePieceItem()
  }

  useEffect(() => {
    updatePieceItem();
  }, [isAutoSave]);

  return (
    <Card
      size='sm'
      direction={{base: 'column', sm: 'row'}}
      overflow='hidden'
      variant='outline'
    >
      <Image
        objectFit='cover'
        maxW={{base: '100%', sm: '100px'}}
        src={`http://localhost:3000/api/pieces/${item.id}/preview`}
        alt='Caffe Latte'
      />

      <Stack>
        <CardBody>
          <Flex gap='2' my='2'>
            <Badge colorScheme='blue'>{item.role}</Badge>
            <Badge colorScheme='green'>{item.type}</Badge>
          </Flex>
          <Heading size='sm'>{item.filePath}</Heading>
          <Text>
            id {item.id}
          </Text>
          <Text>
            hash: {item.fileHash}
          </Text>
          <Text>
            updated: {item.updatedAt}
          </Text>
        </CardBody>

        <CardFooter gap='2' alignItems='center'>
          <FormLabel mb='0' alignItems='center'>
            <Switch isChecked={isAutoSave} onChange={onChangeIsAuthSave} /> auto save
          </FormLabel>

          <Button variant='outline' colorScheme='blue' size='sm' onClick={onReveal}>
            Show in explorer (finder)
          </Button>

        </CardFooter>
      </Stack>
    </Card>
  )
}
