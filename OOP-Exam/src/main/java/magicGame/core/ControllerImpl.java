package magicGame.core;

import magicGame.models.magicians.BlackWidow;
import magicGame.models.magicians.Magician;
import magicGame.models.magicians.Wizard;
import magicGame.models.magics.BlackMagic;
import magicGame.models.magics.Magic;
import magicGame.models.magics.RedMagic;
import magicGame.models.region.Region;
import magicGame.models.region.RegionImpl;
import magicGame.repositories.interfaces.MagicRepositoryImpl;
import magicGame.repositories.interfaces.MagicianRepository;
import magicGame.repositories.interfaces.MagicianRepositoryImpl;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

import static magicGame.common.ExceptionMessages.*;
import static magicGame.common.OutputMessages.SUCCESSFULLY_ADDED_MAGIC;
import static magicGame.common.OutputMessages.SUCCESSFULLY_ADDED_MAGICIAN;

public class ControllerImpl implements Controller {

    private MagicianRepositoryImpl magicians;
    private MagicRepositoryImpl magics;
    private Region region;

    public ControllerImpl() {
        magicians = new MagicianRepositoryImpl();
        magics = new MagicRepositoryImpl();
        region = new RegionImpl();
    }

    @Override
    public String addMagic(String type, String name, int bulletsCount) {
        Magic magic;
        switch (type) {
            case "BlackMagic":
                magic = new BlackMagic(name, bulletsCount);

                break;

            case "RedMagic":
                magic = new RedMagic(name, bulletsCount);
                break;

            default:
                throw new IllegalArgumentException(INVALID_MAGIC_TYPE);
        }
        magics.addMagic(magic);
        return String.format(SUCCESSFULLY_ADDED_MAGIC, name);
    }

    @Override
    public String addMagician(String type, String username, int health, int protection, String magicName) {
        Magician magician;
        Magic magic = (Magic) magics.findByName(magicName);
        if (magic == null) {
            throw new NullPointerException(MAGIC_CANNOT_BE_FOUND);
        }
        switch (type) {
            case "Wizard":
                magician = new Wizard(username, health, protection, magic);
                break;

            case "BlackWidow":
                magician = new BlackWidow(username, health, protection, magic);
                break;
            default:
                throw new IllegalArgumentException(INVALID_MAGICIAN_TYPE);
        }
        magicians.addMagician(magician);
        return String.format(SUCCESSFULLY_ADDED_MAGICIAN, username);
    }

    @Override
    public String startGame() {
        return region.start(magicians.getData());
    }

    @Override
    public String report() {
        StringBuilder sb = new StringBuilder();

        List<Magician> magicianList = (List<Magician>) magicians.getData().stream()
                .sorted(Comparator.comparing(Magician::getHealth)
                        .thenComparing(Magician::getUsername))
                .collect(Collectors.toList());

        for (Magician magician:
             magicianList) {
            int health = magician.getHealth();
            if(magician.getHealth()<0){
            health=0;}

            int protection =magician.getProtection();
            if (protection<0){
                protection=0;
            }

            sb.append(String.format("%s: %s",magician.getClass().getSimpleName(),magician.getUsername())).append(System.lineSeparator() );
            sb.append(String.format("Health: %d",health)).append(System.lineSeparator());
            sb.append(String.format("Protection: %d",protection)).append(System.lineSeparator());
            sb.append(String.format("Magic: %s",magician.getMagic().getName())).append(System.lineSeparator());
        }
        return sb.toString().trim();



    }
}
